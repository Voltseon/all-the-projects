require 'socket'
require 'io/wait'

class Connection
	class Disconnected < Exception; end
	class ProtocolError < StandardError; end

	def self.open(host, port)
		# XXX: Non-blocking connect.
		begin
			socket = TCPSocket.open(host, port)
			connection = Connection.new(socket)
			yield connection
		end
	end

	def initialize(socket)
		@socket = socket
		@socket.sync = true
		@recv_parser = Parser.new
		@recv_records = []
		@discard_records = 0
	end

	def update
		if @socket.nread>0
			recvd = @socket.recv(4096)
			raise Disconnected.new("server disconnected") if recvd.empty?
			@recv_parser.parse(recvd) {|record| @recv_records << record}
		end
		# Process at most one record so that any control flow in the block doesn't cause us to lose records.
		if !@recv_records.empty?
			if @recv_records.length > 5
				until @recv_records.empty?
					record = @recv_records.shift
				end
			else
				record = @recv_records.shift
			end
			if record.disconnect?
				reason = record.str() rescue "unknown error"
				raise Disconnected.new(reason)
				return
			end
			if @discard_records == 0
				begin
					yield record
				rescue
					raise # compat
				else
					raise ProtocolError.new("Unconsumed input: #{record}") if !record.empty?
				end
			else
				@discard_records -= 1
			end
		end
	end

	def can_send?
		return !IO.select(nil, [@socket],nil).nil?
	end

	def send
		# XXX: Non-blocking send.
		# but note we don't update often so we need some sort of drained?
		# for the send buffer so that we can delay starting the battle.
		writer = RecordWriter.new
		yield writer
		@socket.write_nonblock(writer.line!)
	end

	def send_msg(msg)
		# Prefix each message with a 4-byte length (network byte order)
		msg = [msg.bytesize].pack('N') + msg
		@socket.write(msg)
	end
	
  def recv_msg
		# Read message length and unpack it into an integer
		raw_msglen = recvall(4)
		return nil if raw_msglen.nil?
	
		msglen = raw_msglen.unpack('N')[0]
		# Read the message data
		recvall(msglen)
	end
	
	def recvall(n)
		# Helper function to recv n bytes or return nil if EOF is hit
		data = ''
		while data.length < n
			packet = @socket.read(n - data.length)
			return nil if packet.nil?
	
			data << packet
		end
		data
	end

	def discard(n)
		raise "Cannot discard #{n} messages." if n < 0
		@discard_records += n
	end
	
	def dispose
		@socket.close
		@parser = nil
	end
end

class Parser
	def initialize
		@buffer = ""
	end

	def parse(data)
		return if data.empty?
		lines = data.split("\n", -1)
		lines[0].insert(0, @buffer)
		@buffer = lines.pop
		lines.each do |line|
			yield RecordParser.new(line) if !line.empty?
		end
	end
end

class RecordParser
	def initialize(data)
		@fields = []
		field = ""
		escape = false
		# each_char and chars don't exist.
		for i in (0...data.length)
			char = data[i].chr
			if char == "," && !escape
				@fields << field
				field = ""
			elsif char == "\\" && !escape
				escape = true
			else
				field += char
				escape = false
			end
		end
		@fields << field
		@fields.reverse!
	end

	def empty?; return @fields.empty? end

	def disconnect?
		if @fields.last == "disconnect"
			@fields.pop
			return true
		else
			return false
		end
	end

	def nil_or(t)
		raise Connection::ProtocolError.new("Expected nil or #{t}, got EOL") if @fields.empty?
		if @fields.last.empty?
			@fields.pop
			return nil
		else
			return self.send(t)
		end
	end

	def bool
		raise Connection::ProtocolError.new("Expected bool, got EOL") if @fields.empty?
		field = @fields.pop
		if field == "true"
			return true
		elsif field == "false"
			return false
		else
			raise Connection::ProtocolError.new("Expected bool, got #{field}")
		end
	end

	def int
		raise Connection::ProtocolError.new("Expected int, got EOL") if @fields.empty?
		field = @fields.pop
		begin
			return Integer(field)
		rescue
			raise Connection::ProtocolError.new("Expected int, got #{field}")
		end
	end

	def str
		raise Connection::ProtocolError.new("Expected str, got EOL") if @fields.empty?
		@fields.pop
	end

	def sym
		raise Connection::ProtocolError.new("Expected sym, got EOL") if @fields.empty?
		@fields.pop.to_sym
	end

	def flt
		raise Connection::ProtocolError.new("Expected sym, got EOL") if @fields.empty?
		@fields.pop.to_f
	end

	def to_s; @fields.reverse.join(", ") end
end

class RecordWriter
	def initialize
		@fields = []
	end

	def line!
		line = @fields.map {|field| escape!(field)}.join(",")
		line += "\n"
		@fields = []
		return line
	end

	def escape!(s)
		t=s.clone(freeze: false)
		t.gsub!("\\", "\\\\")
		t.gsub!(",", "\,")
		return t
	end

	def nil_or(t, o)
		if o.nil?
			@fields << ""
		else
			self.send(t, o)
		end
	end

	def bool(b); @fields << b.to_s end
	def int(i); @fields << i.to_s end
	def str(s) @fields << s end
	def sym(s); @fields << s.to_s end
	def flt(f); @fields << f.to_s end
end
#===============================================================================
# class Object
#===============================================================================
class Object
	alias full_inspect inspect unless method_defined?(:full_inspect)

	def inspect
		return "#<#{self.class}>"
	end
end

#===============================================================================
# class Class
#===============================================================================
class Class
	def to_sym
		return self.to_s.to_sym
	end
end

#===============================================================================
# class String
#===============================================================================
class String
	def starts_with_vowel?
		return ["a", "e", "i", "o", "u"].include?(self[0, 1].downcase)
	end

	def first(n = 1); return self[0...n]; end

	def last(n = 1); return self[-n..-1] || self; end

	def blank?; return self.strip.empty?; end

	def cut(bitmap, width)
		string = self
		width -= bitmap.text_size("...").width
		string_width = 0
		text = []
		string.scan(/./).each do |char|
			wdh = bitmap.text_size(char).width
			next if (wdh + string_width) > width
			string_width += wdh
			text.push(char)
		end
		text.push("...") if text.length < string.length
		new_string = ""
		text.each do |char|
			new_string += char
		end
		return new_string
	end

	def numeric?
		return !self[/^[+-]?([0-9]+)(?:\.[0-9]+)?$/].nil?
	end
end

#===============================================================================
# class Numeric
#===============================================================================
class Numeric
	# Turns a number into a string formatted like 12,345,678.
	def to_s_formatted
		return self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
	end

	def to_word
		ret = [_INTL("zero"), _INTL("one"), _INTL("two"), _INTL("three"),
					 _INTL("four"), _INTL("five"), _INTL("six"), _INTL("seven"),
					 _INTL("eight"), _INTL("nine"), _INTL("ten"), _INTL("eleven"),
					 _INTL("twelve"), _INTL("thirteen"), _INTL("fourteen"), _INTL("fifteen"),
					 _INTL("sixteen"), _INTL("seventeen"), _INTL("eighteen"), _INTL("nineteen"),
					 _INTL("twenty")]
		return ret[self] if self.is_a?(Integer) && self >= 0 && self <= ret.length
		return self.to_s
	end
end

#===============================================================================
# class Array
#===============================================================================
class Array
	def ^(other)   # xor of two arrays
		return (self | other) - (self & other)
	end

	def swap(val1, val2)
		index1 = self.index(val1)
		index2 = self.index(val2)
		self[index1] = val2
		self[index2] = val1
	end

	def to_rect
		return Rect.new(self[0], self[1], self[2], self[3])
	end
end

#===============================================================================
# class Hash
#===============================================================================
class Hash
	def deep_merge(hash)
		merged_hash = self.clone
		merged_hash.deep_merge!(hash) if hash.is_a?(Hash)
		return merged_hash
	end

	def deep_merge!(hash)
		# failsafe
		return unless hash.is_a?(Hash)
		hash.each do |key, val|
			if self[key].is_a?(Hash)
				self[key].deep_merge!(val)
			else
				self[key] = val
			end
		end
	end
end

#===============================================================================
# module Enumerable
#===============================================================================
module Enumerable
	def transform
		ret = []
		self.each { |item| ret.push(yield(item)) }
		return ret
	end
end

#===============================================================================
# class File
#===============================================================================
class File
	# Copies the source file to the destination path.
	def self.copy(source, destination)
		data = ""
		t = Time.now
		File.open(source, "rb") do |f|
			loop do
				r = f.read(4096)
				break if !r
				if Time.now - t > 1
					Graphics.update
					t = Time.now
				end
				data += r
			end
		end
		File.delete(destination) if File.file?(destination)
		f = File.new(destination, "wb")
		f.write data
		f.close
	end

	# Copies the source to the destination and deletes the source.
	def self.move(source, destination)
		File.copy(source, destination)
		File.delete(source)
	end
end

#===============================================================================
# class Color
#===============================================================================
class Color
	# alias for old constructor
	alias init_original initialize unless self.private_method_defined?(:init_original)

	# New constructor, accepts RGB values as well as a hex number or string value.
	def initialize(*args)
		pbPrintException("Wrong number of arguments! At least 1 is needed!") if args.length < 1
		if args.length == 1
			if args.first.is_a?(Fixnum)
				hex = args.first.to_s(16)
			elsif args.first.is_a?(String)
				try_rgb_format = args.first.split(",")
				return init_original(*try_rgb_format.map(&:to_i)) if try_rgb_format.length.between?(3, 4)
				hex = args.first.delete("#")
			end
			pbPrintException("Wrong type of argument given!") if !hex
			r = hex[0...2].to_i(16)
			g = hex[2...4].to_i(16)
			b = hex[4...6].to_i(16)
		elsif args.length == 3
			r, g, b = *args
		end
		return init_original(r, g, b) if r && g && b
		return init_original(*args)
	end

	# Returns this color as a hex string like "#RRGGBB".
	def to_hex
		r = sprintf("%02X", self.red)
		g = sprintf("%02X", self.green)
		b = sprintf("%02X", self.blue)
		return ("#" + r + g + b).upcase
	end

	# Returns this color as a 24-bit color integer.
	def to_i
		return self.to_hex.delete("#").to_i(16)
	end

	# Converts the provided hex string/24-bit integer to RGB values.
	def self.hex_to_rgb(hex)
		hex = hex.delete("#") if hex.is_a?(String)
		hex = hex.to_s(16) if hex.is_a?(Numeric)
		r = hex[0...2].to_i(16)
		g = hex[2...4].to_i(16)
		b = hex[4...6].to_i(16)
		return r, g, b
	end

	# http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically
	def self.hsv_to_rgb(h, s, v)
		h, s, v = h.to_f/360, s.to_f/100, v.to_f/100
		h_i = (h*6).to_i
		f = h*6 - h_i
		p = v * (1 - s)
		q = v * (1 - f*s)
		t = v * (1 - (1 - f) * s)
		r, g, b = v, t, p if h_i==0
		r, g, b = q, v, p if h_i==1
		r, g, b = p, v, t if h_i==2
		r, g, b = p, q, v if h_i==3
		r, g, b = t, p, v if h_i==4
		r, g, b = v, p, q if h_i==5
		[(r*255).to_i, (g*255).to_i, (b*255).to_i]
	end


	# http://ntlk.net/2011/11/21/convert-rgb-to-hsb-hsv-in-ruby/
	def self.rgb_to_hsv(rgb)
		r = rgb.red / 255.0
		g = rgb.green / 255.0
		b = rgb.blue / 255.0
		max = [r, g, b].max
		min = [r, g, b].min
		delta = max - min
		v = max * 100

		if (max != 0.0)
			s = delta / max *100
		else
			s = 0.0
		end

		if (s == 0.0)
			h = 0.0
		else
			if (r == max)
				h = (g - b) / delta
			elsif (g == max)
				h = 2 + (b - r) / delta
			elsif (b == max)
				h = 4 + (r - g) / delta
			end

			h *= 60.0

			if (h < 0)
				h += 360.0
			end
		end

		[h, s, v]
	end

	# Parses the input as a Color and returns a Color object made from it.
	def self.parse(color)
		case color
		when Color
			return color
		when String, Numeric
			return Color.new(color)
		end
		# returns nothing if wrong input
		return nil
	end

	# Returns color object for some commonly used colors
	def self.red;     return Color.new(255,   0,   0); end
	def self.green;   return Color.new(  0, 255,   0); end
	def self.blue;    return Color.new(  0,   0, 255); end
	def self.black;   return Color.new(  0,   0,   0); end
	def self.white;   return Color.new(255, 255, 255); end
	def self.yellow;  return Color.new(255, 255,   0); end
	def self.magenta; return Color.new(255,   0, 255); end
	def self.teal;    return Color.new(  0, 255, 255); end
	def self.orange;  return Color.new(255, 155,   0); end
	def self.purple;  return Color.new(155,   0, 255); end
	def self.brown;   return Color.new(112,  72,  32); end
end

#===============================================================================
# Wrap code blocks in a class which passes data accessible as instance variables
# within the code block.
#
# wrapper = CallbackWrapper.new { puts @test }
# wrapper.set(test: "Hi")
# wrapper.execute  #=>  "Hi"
#===============================================================================
class CallbackWrapper
	@params = {}

	def initialize(&block)
		@code_block = block
	end

	def execute(given_block = nil, *args)
		execute_block = given_block || @code_block
		@params.each do |key, value|
			args.instance_variable_set("@#{key.to_s}", value)
		end
		args.instance_eval(&execute_block)
	end

	def set(params = {})
		@params = params
	end
end

#===============================================================================
# Kernel methods
#===============================================================================
def rand(*args)
	Kernel.rand(*args)
end

class << Kernel
	alias oldRand rand unless method_defined?(:oldRand)
	def rand(a = nil, b = nil)
		if a.is_a?(Range)
			lo = a.min
			hi = a.max
			return lo + oldRand(hi - lo + 1)
		elsif a.is_a?(Numeric)
			if b.is_a?(Numeric)
				return a + oldRand(b - a + 1)
			else
				return oldRand(a)
			end
		elsif a.nil?
			return oldRand(b)
		end
		return oldRand
	end
end

def nil_or_empty?(string)
	return string.nil? || !string.is_a?(String) || string.size == 0
end

# frozen_string_literal: true
#
# = base64.rb: methods for base64-encoding and -decoding strings
#

# The Base64 module provides for the encoding (#encode64, #strict_encode64,
# #urlsafe_encode64) and decoding (#decode64, #strict_decode64,
# #urlsafe_decode64) of binary data using a Base64 representation.
#
# == Example
#
# A simple encoding and decoding.
#
#     require "base64"
#
#     enc   = Base64.encode64('Send reinforcements')
#                         # -> "U2VuZCByZWluZm9yY2VtZW50cw==\n"
#     plain = Base64.decode64(enc)
#                         # -> "Send reinforcements"
#
# The purpose of using base64 to encode data is that it translates any
# binary data into purely printable characters.

module Base64
	module_function
  
	# Returns the Base64-encoded version of +bin+.
	# This method complies with RFC 2045.
	# Line feeds are added to every 60 encoded characters.
	#
	#    require 'base64'
	#    Base64.encode64("Now is the time for all good coders\nto learn Ruby")
	#
	# <i>Generates:</i>
	#
	#    Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4g
	#    UnVieQ==
	def encode64(bin)
	  [bin].pack("m")
	end
  
	# Returns the Base64-decoded version of +str+.
	# This method complies with RFC 2045.
	# Characters outside the base alphabet are ignored.
	#
	#   require 'base64'
	#   str = 'VGhpcyBpcyBsaW5lIG9uZQpUaGlzIG' +
	#         'lzIGxpbmUgdHdvClRoaXMgaXMgbGlu' +
	#         'ZSB0aHJlZQpBbmQgc28gb24uLi4K'
	#   puts Base64.decode64(str)
	#
	# <i>Generates:</i>
	#
	#    This is line one
	#    This is line two
	#    This is line three
	#    And so on...
	def decode64(str)
	  str.unpack1("m")
	end
  
	# Returns the Base64-encoded version of +bin+.
	# This method complies with RFC 4648.
	# No line feeds are added.
	def strict_encode64(bin)
	  [bin].pack("m0")
	end
  
	# Returns the Base64-decoded version of +str+.
	# This method complies with RFC 4648.
	# ArgumentError is raised if +str+ is incorrectly padded or contains
	# non-alphabet characters.  Note that CR or LF are also rejected.
	def strict_decode64(str)
	  str.unpack1("m0")
	end
  
	# Returns the Base64-encoded version of +bin+.
	# This method complies with ``Base 64 Encoding with URL and Filename Safe
	# Alphabet'' in RFC 4648.
	# The alphabet uses '-' instead of '+' and '_' instead of '/'.
	# Note that the result can still contain '='.
	# You can remove the padding by setting +padding+ as false.
	def urlsafe_encode64(bin, padding: true)
	  str = strict_encode64(bin)
	  str.chomp!("==") or str.chomp!("=") unless padding
	  str.tr!("+/", "-_")
	  str
	end
  
	# Returns the Base64-decoded version of +str+.
	# This method complies with ``Base 64 Encoding with URL and Filename Safe
	# Alphabet'' in RFC 4648.
	# The alphabet uses '-' instead of '+' and '_' instead of '/'.
	#
	# The padding character is optional.
	# This method accepts both correctly-padded and unpadded input.
	# Note that it still rejects incorrectly-padded input.
	def urlsafe_decode64(str)
	  # NOTE: RFC 4648 does say nothing about unpadded input, but says that
	  # "the excess pad characters MAY also be ignored", so it is inferred that
	  # unpadded input is also acceptable.
	  if !str.end_with?("=") && str.length % 4 != 0
		str = str.ljust((str.length + 3) & ~3, "=")
		str.tr!("-_", "+/")
	  else
		str = str.tr("-_", "+/")
	  end
	  strict_decode64(str)
	end
  end
  
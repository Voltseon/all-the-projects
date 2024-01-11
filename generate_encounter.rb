def rf
  pok = []
  chance = []
  level = 0
  idx = 0
  file = File.open("generate_enc.txt", "r")
  file.each_line { |line|
    if idx == 0
      level = line.gsub("\n","")
      idx += 1
      next
    end
    l = line.split("	")
    chance.push(l[0].gsub("%","").to_i)
    pok.push(l[1].gsub("\n","").upcase)
    idx += 1
  }
  data = ""
  chance.each_with_index do |c, i|
    data << "  #{c},#{pok[i]},#{level}\n"
  end
  data.replace(data[0..-2])
  return data
end

def read
  data = ""
  file = File.open("generate_enc_out.txt", "r")
  file.each_line { |line|
    data << line
  }
  return data
end

begin
  loop do
    data = rf
    current = read
    unless data == current
      File.open("generate_enc_out.txt", "w") { |file| file.write(data) }
    end
  end
rescue
  puts $!
end
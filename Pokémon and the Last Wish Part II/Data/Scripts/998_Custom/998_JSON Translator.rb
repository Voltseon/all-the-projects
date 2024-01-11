#===============================================================================
# JSON Encoder/Decoder
# Version 1.1
# Author: game_guy
#-------------------------------------------------------------------------------
# Intro:
# JSON (JavaScript Object Notation) is a lightweight data-interchange
# format. It is easy for humans to read and write. It is easy for machines to
# parse and generate.
# This is a simple JSON Parser or Decoder. It'll take JSON thats been
# formatted into a string and decode it into the proper object.
# This script can also encode certain ruby objects into JSON.
#
# Features:
# Decodes JSON format into ruby strings, arrays, hashes, integers, booleans.
#
# Instructions:
# This is a scripters utility. To decode JSON data, call
# JSON.decode("json string")
# -Depending on "json string", this method can return any of the values:
#  -Integer
#  -String
#  -Boolean
#  -Hash
#  -Array
#  -Nil
#
# To Encode objects, use
# JSON.encode(object)
# -This will return A string with JSON. Object can be any one of the following
#  -Integer
#  -String
#  -Boolean
#  -Hash
#  -Array
#  -Nil
#
# CREDITS:
# game_guy ~ Creating it.
#===============================================================================
module JSON
 
  TOKEN_NONE = 0;
  TOKEN_CURLY_OPEN = 1;
  TOKEN_CURLY_CLOSED = 2;
  TOKEN_SQUARED_OPEN = 3;
  TOKEN_SQUARED_CLOSED = 4;
  TOKEN_COLON = 5;
  TOKEN_COMMA = 6;
  TOKEN_STRING = 7;
  TOKEN_NUMBER = 8;
  TOKEN_TRUE = 9;
  TOKEN_FALSE = 10;
  TOKEN_NULL = 11;
 
  @index = 0
  @json = ""
  @length = 0
 
  def self.decode(json)
#    File.open("data.json", 'w') { |file| file.write(json) }
    @json = json
    @index = 0
    @length = @json.length
    return self.parse
  end
 
  def self.encode(obj)
    if obj.is_a?(Hash)
      return self.encode_hash(obj)
    elsif obj.is_a?(Array)
      return self.encode_array(obj)
    elsif obj.is_a?(Fixnum) || obj.is_a?(Float) || obj.is_a?(Integer)
      return self.encode_integer(obj)
    elsif obj.is_a?(String)
      return self.encode_string(obj)
    elsif obj.is_a?(TrueClass) || obj.is_a?(FalseClass)
      return self.encode_bool(obj)
    elsif obj.is_a?(NilClass)
      return "null"
    elsif obj.is_a?(Object)
      return encode_object(obj)
    end
    return nil
  end
  
  
  specificAttrs = [""]
  
  def self.encode_object(o)
    s = "{"
    a = o.instance_variables
        for i in 0..(a.length - 1)
            v = a[i]
            if v.nil?
                next
            end
            vname= v
            va = o.instance_variable_get(v)
            if v[0..0] == '@'
                vname[0..0] = ''
            end
            s = s + "\"" + v + "\": "
            if !va.nil?
                s = s + self.encode(va)
                if i != a.length - 1
                    s = s + " ,"
                end
            else
                s = s + "\"\","
            end
        end
    if o.respond_to? :jsonarr
      methodarr = o.jsonarr
      for i in 0..(methodarr.length - 1)
        sarr = methodarr[i].to_s.split('#')
        methodname = sarr[sarr.length - 1].chomp('>').chomp('?')
        if (s[-1, 1]) != ','
            s += " ,"
        end
          
        s += "\"" + methodname + "\": " + self.encode(methodarr[i].call)
      end
    end
    
        return s + "}"
  end
 
  def self.encode_hash(hash)
    string = "{"
    hash.each_key {|key|
      string += "\"#{key}\":" + self.encode(hash[key]).to_s + ","
    }
    string[string.size - 1, 1] = "}"
    return string
  end
  def self.encode_array(array)
    string = "["
    array.each {|i|
      string += self.encode(i).to_s + ","
    }
    if string.length > 1
        string[string.size - 1, 1] = "]"
    else
        string += "]"
    end
    return string
  end
 
  def self.encode_string(string)
    return "\"#{string}\""
  end
 
  def self.encode_integer(int)
    return int.to_s
  end
 
  def self.encode_bool(bool)
    return (bool.is_a?(TrueClass) ? "true" : "false")
  end
 
  def self.next_token(debug = 0)
    char = @json[@index, 1]
    @index += 1
    case char
    when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-'
      return TOKEN_NUMBER
    when '{'
      return TOKEN_CURLY_OPEN
    when '}'
      return TOKEN_CURLY_CLOSED
    when '"'
      return TOKEN_STRING
    when ','
      return TOKEN_COMMA
    when '['
      return TOKEN_SQUARED_OPEN
    when ']'
      return TOKEN_SQUARED_CLOSED
    when ':'
      return TOKEN_COLON
    when ' '
      return self.next_token
    end
    @index -= 1
    if @json[@index, 5] == "false"
      @index += 5
      return TOKEN_FALSE
    elsif @json[@index, 4] == "true"
      @index += 4
      return TOKEN_TRUE
    elsif @json[@index, 4] == "null"
      @index += 4
      return TOKEN_NULL
    end
    return TOKEN_NONE
  end
  def self.parse(debug = 0)
    complete = false
    while !complete
      if @index >= @length
        break
      end
      token = self.next_token
      case token
      when TOKEN_NONE
        return nil
      when TOKEN_NUMBER
        return self.parse_number
      when TOKEN_CURLY_OPEN
        return self.parse_object
      when TOKEN_STRING
        return self.parse_string
      when TOKEN_SQUARED_OPEN
        return self.parse_array
      when TOKEN_TRUE
        return true
      when TOKEN_FALSE
        return false
      when TOKEN_NULL
        return nil
      end
    end
  end
 
  def self.parse_object
    obj = {}
    complete = false
    while !complete
      token = self.next_token
      if token == TOKEN_CURLY_CLOSED
        complete = true
        break
      elsif token == TOKEN_NONE
        Kernel.pbMessage(@json[@index - 8, 8])
        return nil
      elsif token == TOKEN_COMMA
      else
        name = self.parse_string
        return nil if name == nil
        token = self.next_token
        if token != TOKEN_COLON
          raise "wrong token"
          return null
        end
        value = self.parse
        obj[name] = value
      end
    end
    return obj
  end
 
  def self.parse_string
    complete = false
    string = ""
    while !complete
      break if @index >= @length
      char = @json[@index, 1]
      oldchar = @json[@index - 1, 1]
      @index += 1
      if char == '"' && oldchar != "\\"
        complete = true
        break
      else
        string += char.to_s
      end
    end
    if !complete
      raise "incomplete string"
      return nil
    end
    return string
  end
 
  def self.parse_number
    @index -= 1
    negative = @json[@index, 1] == "-" ? true : false
    string = ""
    complete = false
    while !complete
      break if @index >= @length
      char = @json[@index, 1]
      @index += 1
      case char
      when "{", "}", ":", ",", "[", "]"
        @index -= 1
        complete = true
        break
      when "0", "1", "2", '3', '4', '5', '6', '7', '8', '9'
        string += char.to_s
      end
    end
    return string.to_i
  end
 
  def self.parse_array
    obj = []
    complete = false
    while !complete
      token = self.next_token(1)
      if token == TOKEN_SQUARED_CLOSED
        complete = true
        break
      elsif token == TOKEN_NONE
        raise "null token array"
        return nil
      elsif token == TOKEN_COMMA
      else
        @index -= 1
        value = self.parse
        obj.push(value)
      end
    end
    return obj
  end

end
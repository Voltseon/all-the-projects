#===============================================================================
#  Discord Webhook Posting
#    by Luka S.J.
#-------------------------------------------------------------------------------
# Module used to parse a Ruby Hash structure into properly formatted JSON
# and posts this data to a Discord Webhook through the use of CURL
#===============================================================================
# set up plugin metadata
if defined?(PluginManager)
  PluginManager.register({
    :name => "Post to Discord Webhooks",
    :version => "1.0",
    :credits => ["Luka S.J."],
    :link => "https://luka-sj.com/res/webh"
  })
end
#===============================================================================
module DiscordWebhooks
  #-----------------------------------------------------------------------------
  # recursive method to generate proper string for variable type
  #-----------------------------------------------------------------------------
  def self.element(input)
    if input.is_a?(String)
      return "\\\"#{input}\\\""
    elsif input.is_a?(Numeric) || input.is_a?(TrueClass) || input.is_a?(FalseClass) 
      return "#{input}"
    elsif input.is_a?(Array)
      return self.arrToStr(input)
    elsif input.is_a?(Hash)
      return self.hashToStr(input)
    elsif input.nil?
      return "null"
    else
      return ""
    end
  end
  #-----------------------------------------------------------------------------
  # converts a Ruby Hash to a compatible JSON CURL string
  #-----------------------------------------------------------------------------
  def self.hashToStr(data)
    str = "{"
    i = 1
    for key in data.keys
      str += "#{self.element(key)} : #{self.element(data[key])}"
      str += "," if i < data.keys.length
      i += 1
    end
    str += "}"
    return str
  end
  #-----------------------------------------------------------------------------
  # converts a Ruby Array to a compatible JSON CURL string
  #-----------------------------------------------------------------------------
  def self.arrToStr(data)
    str = "["
    i = 1
    for val in data
      str += self.element(val)
      str += "," if i < data.length
      i += 1
    end
    str += "]"
    return str
  end
  #-----------------------------------------------------------------------------
  # parses entire data structure into proper JSON CURL string
  #-----------------------------------------------------------------------------
  def self.parse(data = {})
    return self.element(data)
  end
  #-----------------------------------------------------------------------------
  # posts Hash data to a Discord Webhook
  #-----------------------------------------------------------------------------
  def self.post(url, data)
    data = self.parse(data)
    cmd = "curl -d \"#{data}\" -H \"Content-Type: application/json\" -X POST #{url}"
    system(cmd)
  end
  #-----------------------------------------------------------------------------
end
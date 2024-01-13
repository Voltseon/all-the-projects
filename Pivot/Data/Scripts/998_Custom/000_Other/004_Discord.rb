require 'discord'

module Graphics
  class << self
      alias discord_update__ update unless method_defined?(:discord_update__)
  end

  def self.update
      Discord.update
      discord_update__
  end
end

Discord.connect
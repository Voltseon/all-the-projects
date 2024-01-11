# If a Pokémon's gender ratio is none of :AlwaysMale, :AlwaysFemale or
# :Genderless, then it will choose a random number between 0 and 255 inclusive,
# and compare it to the @female_chance. If the random number is lower than this
# chance, it will be female; otherwise, it will be male.
module GameData
  class GenderRatio
    attr_reader :id
    attr_reader :real_name
    attr_reader :female_chance
    attr_reader :message

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name] || "Unnamed"
      @female_chance = hash[:female_chance]
      @message       = hash[:message] || "None"
    end

    # @return [String] the translated name of this gender ratio
    def name
      return _INTL(@real_name)
    end

    # @return [Boolean] whether a Pokémon with this gender ratio can only ever
    #   be a single gender
    def single_gendered?
      return @female_chance.nil?
    end
  end
end

#===============================================================================

GameData::GenderRatio.register({
  :id            => :AlwaysMale,
  :name          => _INTL("Always Male"),
  :message       => _INTL("100% Male")
})

GameData::GenderRatio.register({
  :id            => :AlwaysFemale,
  :name          => _INTL("Always Female"),
  :message       => _INTL("100% Female")
})

GameData::GenderRatio.register({
  :id            => :Genderless,
  :name          => _INTL("Genderless"),
  :message       => _INTL("Genderless")
})

GameData::GenderRatio.register({
  :id            => :FemaleOneEighth,
  :name          => _INTL("Female One Eighth"),
  :female_chance => 32,
  :message       => _INTL("12.5% Female")
})

GameData::GenderRatio.register({
  :id            => :Female25Percent,
  :name          => _INTL("Female 25 Percent"),
  :female_chance => 64,
  :message       => _INTL("25% Female")
})

GameData::GenderRatio.register({
  :id            => :Female50Percent,
  :name          => _INTL("Female 50 Percent"),
  :female_chance => 128,
  :message       => _INTL("50/50")
})

GameData::GenderRatio.register({
  :id            => :Female75Percent,
  :name          => _INTL("Female 75 Percent"),
  :female_chance => 192,
  :message       => _INTL("25% Male")
})

GameData::GenderRatio.register({
  :id            => :FemaleSevenEighths,
  :name          => _INTL("Female Seven Eighths"),
  :female_chance => 224,
  :message       => _INTL("12.5% Male")
})

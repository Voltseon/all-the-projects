module GameData
  class SecretBaseSkill
    attr_reader :id
    attr_reader :real_name
    attr_reader :usage_proc

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id              = hash[:id]
      @real_name       = hash[:name]        || "Unnamed"
      @usage_proc      = hash[:usage_proc]
    end
    
    # @return [String] the translated name of this egg group
    def name
      return _INTL(@real_name)
    end
    
    def call_usage(*args)
      return (@usage_proc) ? @usage_proc.call(*args) : nil
    end
  end
end

GameData::SecretBaseSkill.register({
  :id         => :EV_Training,
  :name       => _INTL("Do some exercise"),
  :usage_proc => proc {|owner|
    pbMessage(_INTL("{1}: Which Pokémon should I train?"))
    chosen = 0
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      chosen = screen.pbChooseAblePokemon(proc {|pkmn| !pkmn.egg?}, false)
    }
  }
})

GameData::SecretBaseSkill.register({
  :id         => :Level_Training,
  :name       => _INTL("Do some training"),
  :usage_proc => proc {|owner|
    pbMessage(_INTL("{1}: Which Pokémon should I train?\\1",owner.name))
    chosen = 0
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      chosen = screen.pbChooseAblePokemon(proc {|pkmn| !pkmn.egg? && pkmn.level < GameData::GrowthRate.max_level}, false)
    }
    next false if chosen<0
    pkmn = $player.party[chosen]
    pbMessage(_INTL("{1}: Looks like this one could use some training! OK! Here I go.\\1",owner.name))
    pbMessage(_INTL("{1}: {2}!\\nKeep going! You've got it!\\1",owner.name,pkmn.name))
    pbMessage(_INTL("{2}!\\nThat's it, exactly!\\1",owner.name,pkmn.name))
    pbMessage(_INTL("{1}: That was a great training session!\\1",owner.name))
    pbChangeLevel(pkmn, pkmn.level + 1, nil)
    next true
  }
})

GameData::SecretBaseSkill.register({
  :id         => :Give_Decoration,
  :name       => _INTL("Make some goods"),
  :usage_proc => proc {|owner|
    pbMessage(_INTL("{1}: OK! I'm itching to start! Here I go.\\1",owner.name))
    next true
  }
})
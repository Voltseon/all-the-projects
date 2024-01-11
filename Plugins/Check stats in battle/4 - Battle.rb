begin
	module PBEffects
		STORE_SPECIES = 500
	end
rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end

class Battle::Battler
	alias check_stat_init_effect pbInitEffects
	alias check_stat_transform pbTransform

	def pbInitEffects(batonPass)
		check_stat_init_effect(batonPass)
		@effects[PBEffects::STORE_SPECIES] = 0
	end

	def pbTransform(target)
		@effects[PBEffects::STORE_SPECIES] = target
		check_stat_transform(target)
	end
end

class Battle

	def get_owner_name_change_stats(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
		# Opponent
    return @opponent[idxTrainer].name if opposes?(idxBattler)
		# Ally trainer
    return @player[idxTrainer].name if idxTrainer > 0
		# Player
    return @player[idxTrainer].name
	end

	def array_change_stats_in_battle(side=0)
		ret = {}
		[:player, :opponent].each_with_index { |name, i|
			ret[name] = {
				:name => [],
				:pkmn => []
			}
			@battlers.each_with_index { |pkmn, j|
				next unless pkmn && !pkmn.fainted? && !pkmn.opposes?(i)
				ret[name][:pkmn] << pkmn
			}
		}
		# Name of player
		@battlers.each_with_index { |pkmn, i|
			next unless pkmn && !pkmn.fainted?
			if i.even?
				ret[:player][:name] << get_owner_name_change_stats(i)
			else
				next if wildBattle?
				ret[:opponent][:name] << get_owner_name_change_stats(i)
			end
		}
		# Player
		return ret[:player] if side == 0
		# Opponent
		return ret[:opponent]
	end

	#------------#
	# Get active #
	#------------#
	# Used in class Battle::ActiveField
	def active_field
		ret = {}
		@field.effects.each_with_index { |effect, i|
			next if effect.nil?
			next if !effect || effect == 0
			case i
			when PBEffects::AmuletCoin      then ret["Amulet coin"]       = effect
			when PBEffects::FairyLock       then ret["Fairy lock"]        = effect
			when PBEffects::FusionBolt      then ret["Fusion bolt"]       = effect
			when PBEffects::FusionFlare     then ret["Fusion flare"]      = effect
			when PBEffects::Gravity         then ret["Gravity"]           = effect
			when PBEffects::HappyHour       then ret["Happy hour"]        = effect
			when PBEffects::IonDeluge       then ret["Ion deluge"]        = effect
			when PBEffects::MagicRoom       then ret["Magic room"]        = effect
			when PBEffects::MudSportField   then ret["Mud sport field"]   = effect
			when PBEffects::PayDay          then ret["Pay day"]           = effect
			when PBEffects::TrickRoom       then ret["Trick room"]        = effect
			when PBEffects::WaterSportField then ret["Water sport field"] = effect
			when PBEffects::WonderRoom      then ret["Wonder room"]       = effect
			end
		}
		ret["Default weather"] = @field.defaultWeather.to_s.capitalize if @field.defaultWeather != :None
		ret["Weather"] = @field.weather.to_s.capitalize if @field.weather != :None
		ret["Weather duration"] = @field.weatherDuration if @field.weatherDuration != 0
		ret["Default terrain"] = @field.defaultTerrain.to_s.capitalize if @field.defaultTerrain != :None
		ret["Terrain"] = @field.terrain.to_s.capitalize if @field.terrain != :None
		ret["Terrain duration"] = @field.terrainDuration if @field.terrainDuration != 0
		return ret
	end

	# Used in class Battle::ActiveSide
	def active_side
		ret = [{}, {}]
		ret.each_with_index { |_, i|
			@sides[i].effects.each_with_index { |effect, j|
				next if effect.nil?
				next if !effect
				case j
				when PBEffects::AuroraVeil         then ret[i]["Aurora veil"]          = effect if !effect.zero?
				when PBEffects::CraftyShield       then ret[i]["Crafty shield"]        = effect
				when PBEffects::EchoedVoiceCounter then ret[i]["Echoed voice counter"] = effect if !effect.zero?
				when PBEffects::EchoedVoiceUsed    then ret[i]["Echoed voice used"]    = effect
				when PBEffects::LastRoundFainted   then ret[i]["Last round fainted"]   = effect if effect != -1
				when PBEffects::LightScreen        then ret[i]["Light screen"]         = effect if !effect.zero?
				when PBEffects::LuckyChant         then ret[i]["Lucky chant"]          = effect if !effect.zero?
				when PBEffects::MatBlock           then ret[i]["MatBlock"]             = effect
				when PBEffects::Mist               then ret[i]["Mist"]                 = effect if !effect.zero?
				when PBEffects::QuickGuard         then ret[i]["Quick guard"]          = effect
				when PBEffects::Rainbow            then ret[i]["Rainbow"]              = effect if !effect.zero?
				when PBEffects::Reflect            then ret[i]["Reflect"]              = effect if !effect.zero?
				when PBEffects::Round              then ret[i]["Round"]                = effect
				when PBEffects::Safeguard          then ret[i]["Safeguard"]            = effect if !effect.zero?
				when PBEffects::SeaOfFire          then ret[i]["Sea of fire"]          = effect if !effect.zero?
				when PBEffects::Spikes             then ret[i]["Spikes"]               = effect if !effect.zero?
        when PBEffects::ShadowTraps        then ret[i]["ShadowTraps"]          = effect if !effect.zero?
				when PBEffects::StealthRock        then ret[i]["Stealth rock"]         = effect
				when PBEffects::StickyWeb          then ret[i]["Sticky web"]           = effect
				when PBEffects::Swamp              then ret[i]["Swamp"]                = effect if !effect.zero?
				when PBEffects::Tailwind           then ret[i]["Tailwind"]             = effect if !effect.zero?
				when PBEffects::ToxicSpikes        then ret[i]["Toxic spikes"]         = effect if !effect.zero?
				when PBEffects::WideGuard          then ret[i]["Wide guard"]           = effect
				end
			}
		}
		return ret
	end

	# Used in class Battle::ActivePosition
	def active_position
		ret = []
		@positions.each_with_index { |pos, i|
			pkmn = @battlers[i]
			ret << {}
			next unless pkmn && !pkmn.fainted?
			pos.effects.each_with_index { |effect, j|
				case j
				when PBEffects::FutureSightCounter        then ret[i]["Future sight counter"]          = effect if effect != 0
				when PBEffects::FutureSightMove           then ret[i]["Future sight move"]             = effect.to_s.capitalize if !effect.nil?
				when PBEffects::FutureSightUserIndex      then ret[i]["Future sight user index"]       = effect if effect != -1
				when PBEffects::FutureSightUserPartyIndex then ret[i]["Future sight user party index"] = effect if effect != -1
				when PBEffects::HealingWish               then ret[i]["Healing wish"]                  = effect if effect
				when PBEffects::LunarDance                then ret[i]["Lunar dance"]                   = effect if effect
				when PBEffects::Wish                      then ret[i]["Wish"]                          = effect if !effect.zero?
				when PBEffects::WishAmount                then ret[i]["Wish Amount"]                   = effect if !effect.zero?
				when PBEffects::WishMaker                 then ret[i]["Wish maker"]                    = effect if effect != -1
				end
			}
		}
		return ret
	end

end
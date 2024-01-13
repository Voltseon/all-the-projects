class DayCare
  class DayCareSlot; end;
end
class SafariState; end;
class PurifyChamber; end;
class PurifyChamberSet; end;
class PokemonBag; end;
class PokemonStorage; end;
class PokemonBox; end;
#===============================================================================
# Conversions required to support backwards compatibility with old save files
# (within reason).
#===============================================================================

SaveData.register_conversion(:v20_refactor_follower_data) do
  essentials_version 20
  display_title "Updating follower data format"
  to_value :global_metadata do |global|
    # NOTE: dependentEvents is still defined in class PokemonGlobalMetadata just
    #       for the sake of this conversion. It will be removed in future.
    if global.dependentEvents && global.dependentEvents.length > 0
      global.followers = []
      global.dependentEvents.each do |follower|
        data = FollowerData.new(follower[0], follower[1], "reflection",
                                follower[2], follower[3], follower[4],
                                follower[5], follower[6], follower[7])
        data.name            = follower[8]
        data.common_event_id = follower[9]
        global.followers.push(data)
      end
    end
    global.dependentEvents = nil
  end
end

#===============================================================================

SaveData.register_conversion(:v1_0_1_refactor_day_care_variables) do
  game_version "1.0.1"
  to_value :global_metadata do |global|
    global.instance_eval do
      @day_care = nil
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v1_0_1_rename_bag_variables) do
  game_version "1.0.1"
  to_value :bag do |bag|
    bag.instance_eval do
      @bag = nil
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_increment_player_character_id) do
  essentials_version 20
  display_title "Incrementing player character ID"
  to_value :player do |player|
    player.character_ID += 1
  end
end

#===============================================================================

SaveData.register_conversion(:v20_add_pokedex_records) do
  essentials_version 20
  display_title "Adding more Pokédex records"
  to_value :player do |player|
    player.pokedex.instance_eval do
      @caught_counts = {} if @caught_counts.nil?
      @defeated_counts = {} if @defeated_counts.nil?
      @seen_eggs = {} if @seen_eggs.nil?
      @seen_forms.each_value do |sp|
        next if !sp || sp[0][0].is_a?(Array)   # Already converted to include shininess
        sp[0] = [sp[0], []]
        sp[1] = [sp[1], []]
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_add_new_default_options) do
  essentials_version 20
  display_title "Updating Options to include new settings"
  to_value :pokemon_system do |option|
    option.givenicknames = 0 if option.givenicknames.nil?
    option.sendtoboxes = 0 if option.sendtoboxes.nil?
  end
end

#===============================================================================

SaveData.register_conversion(:v20_fix_default_weather_type) do
  essentials_version 20
  display_title "Fixing weather type 0 in effect"
  to_value :game_screen do |game_screen|
    game_screen.instance_eval do
      @weather_type = :None if @weather_type == 0
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_add_stats) do
  essentials_version 20
  display_title "Adding stats to save data"
  to_all do |save_data|
    unless save_data.has_key?(:stats)
      save_data[:stats] = GameStats.new
      save_data[:stats].play_time = save_data[:frame_count].to_f / Graphics.frame_rate
      save_data[:stats].play_sessions = 1
      save_data[:stats].time_last_saved = save_data[:stats].play_time
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_convert_pokemon_markings) do
  essentials_version 20
  display_title "Updating format of Pokémon markings"
  to_all do |save_data|
    # Create a lambda function that updates a Pokémon's markings
    update_markings = lambda do |pkmn|
      return if !pkmn || !pkmn.markings.is_a?(Integer)
      markings = []
      6.times { |i| markings[i] = ((pkmn.markings & (1 << i)) == 0) ? 0 : 1 }
      pkmn.markings = markings
    end
    # Party Pokémon
    save_data[:player].party.each { |pkmn| update_markings.call(pkmn) }
    # Pokémon storage
    save_data[:storage_system].boxes.each do |box|
      box.pokemon.each { |pkmn| update_markings.call(pkmn) if pkmn }
    end
    # NOTE: Pokémon in the Day Care have their markings converted above.
    # Partner trainer
    if save_data[:global_metadata].partner
      save_data[:global_metadata].partner[3].each { |pkmn| update_markings.call(pkmn) }
    end
    # Roaming Pokémon
    if save_data[:global_metadata].roamPokemon
      save_data[:global_metadata].roamPokemon.each { |pkmn| update_markings.call(pkmn) }
    end
    # Purify Chamber
    save_data[:global_metadata].purifyChamber.sets.each do |set|
      set.list.each { |pkmn| update_markings.call(pkmn) }
      update_markings.call(set.shadow) if set.shadow
    end
    # Hall of Fame records
    if save_data[:global_metadata].hallOfFame
      save_data[:global_metadata].hallOfFame.each do |team|
        next if !team
        team.each { |pkmn| update_markings.call(pkmn) }
      end
    end
    # Pokémon stored in Game Variables for some reason
    variables = save_data[:variables]
    (0..5000).each do |i|
      value = variables[i]
      case value
      when Array
        value.each { |value2| update_markings.call(value2) if value2.is_a?(Pokemon) }
      when Pokemon
        update_markings.call(value)
      end
    end
  end
end

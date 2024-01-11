class ItemLog; end;
class Player_Quests; end;
class Quest; end;
class QuestData; end;
class ControlConfig; end;
class PANTSMission; end;

GAMES = [
  "Pivot",
  "Pokémon Shattered Light",
  "Pokemon and the Last Wish",
  "Pokemon and the Last Wish Part II",
  "Pokémon Outbounds",
  "Pokémon Syvin",
  "Pokemon Flux",
  "Littleroot Researchers",
  "Pokémon Infinity",
  "Pokemon Bushido",
  "Pokemon Beekeeper",
  "Pokemon Quantum",
  "Pokemon This Gym of Mine"
]

IGNORED_NAMES = [
  "Player",
  "Red"
]

# Looks through all save files and returns the most common player name.
def get_player_name(debug = false)
  names = []
  for game in GAMES
    echoln "- Checking \"#{game}\"..." if debug
    save = pbSaveFile(game)
    save = pbSaveFile(game, 18) if !save
    if !save
      echoln "  X No save file found." if debug
      next
    end
    name = save[:player].name
    echoln "  ✓ Found name: \"#{name}\"" if debug
    names.push(name) if name && !IGNORED_NAMES.include?(name)
  end
  echoln "- All found names: #{names}" if debug
  names = names.group_by(&:downcase).values.max_by(&:size)
  echoln "\n- Most Common Name: \"#{names.first}\"" if debug
  return names ? names.first : ""
end
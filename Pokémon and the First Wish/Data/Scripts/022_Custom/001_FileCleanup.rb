def remove_followers
  Dir.foreach('Graphics/Characters/Followers') do |filename|
    next if filename == '.' or filename == '..'
    pkmn = GameData::Species.try_get(filename.gsub('.png', ''))
    if pkmn.nil?
      echoln filename
      next
    end
    File.delete('Graphics/Characters/Followers/' + filename) if [6,7,8].include?(pkmn.generation)
  end
  Dir.foreach('Graphics/Characters/Followers shiny') do |filename|
    next if filename == '.' or filename == '..'
    pkmn = GameData::Species.try_get(filename.gsub('.png', ''))
    if pkmn.nil?
      echoln filename
      next
    end
    File.delete('Graphics/Characters/Followers shiny/' + filename) if [6,7,8].include?(pkmn.generation)
  end
end
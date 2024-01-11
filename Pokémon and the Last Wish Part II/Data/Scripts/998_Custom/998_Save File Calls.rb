def pbSaveFile(name,ver=19)
  case ver
    when 19
      location = File.join("C:/Users",System.user_name,"AppData/Roaming",name)
      return false unless File.directory?(location)
      file = File.join(location, 'Game.rxdata')
      return false unless File.file?(file)
      save_data = SaveData.read_from_file(file)
    when 18
      home = ENV['HOME'] || ENV['HOMEPATH']
      return false if home.nil?
      location = File.join(home, 'Saved Games', name)
      return false unless File.directory?(location)
      file = File.join(location, 'Game.rxdata')
      return false unless File.file?(file)
      save_data = SaveData.get_data_from_file(file).clone
      save_data = SaveData.to_hash_format(save_data) if save_data.is_a?(Array)
  end
  return save_data
end



def pbSaveTest(name,test,param=nil,ver=19)
  save = pbSaveFile(name,ver)
  result = false
  test = test.capitalize
  if save
    case test
      when "Exist"
        result = true
      when "Map"
        result = (save[:map_factory].map.map_id == param)
      when "Name"
        result = (save[:player].name == param)
      when "Switch"
        result = (save[:switches][param] == true)
      when "Variable"
        varnum = param[0]
        varval = param[1]
        if varval.is_a?(Numeric)
          result = (save[:variables][varnum] >= varval)
        else
          result = (save[:variables][varnum] == varval)
        end
      when "Party"
        party = save[:player].party
        for i in 0...party.length
          poke = party[i]
          result = true if poke.species == param
        end
      when "Seen"
        result = (save[:player].pokedex.seen?(param))
      when "Owned"
        result = (save[:player].pokedex.owned?(param))
      when "Item"
        result = (save[:bag].pbHasItem?(param))
    end
  end
  return result
end
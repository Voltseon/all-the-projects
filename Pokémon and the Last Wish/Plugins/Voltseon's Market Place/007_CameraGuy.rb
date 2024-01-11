


def addParty(args)
  FollowingPkmn.toggle_off(false)
  $Trainer.party.each_with_index do |pkmn, index|
    x_offset = 0
    y_offset = 0
    next if pkmn.egg?
    case index
    when 0
      x_offset = 2
    when 1
      x_offset = 1
      y_offset = -1
    when 2
      x_offset = -1
      y_offset = -1
    when 3
      y_offset = -1
    when 4
      x_offset = 3
      y_offset = -1
    when 5
      x_offset = 2
      y_offset = -1
    end
    thisevent = getEventFromID($game_map.map_id,args[index])
    fname = _INTL("Followers/")
    fname = _INTL("Followers shiny/") if pkmn.shiny?
    fname += _INTL("{1}",GameData::Species.get(pkmn.species).id)
    fname += _INTL("_{1}",pkmn.form) if pkmn.form>0
    fname += _INTL(".png")
    thisevent.character_name = fname
    thisevent.character_hue = 0
    #thisevent.pbMoveRoute([PBMoveRoute::StopAnimation,true])
    thisevent.setVariable([thisevent.x, thisevent.y])
    thisevent.moveto($game_player.x + x_offset, $game_player.y + y_offset)
  end
end

def resetParty(args)
  FollowingPkmn.toggle_on(false)
  $Trainer.party.each_with_index do |pkmn, index|
    next if pkmn.egg?
    thisevent = getEventFromID($game_map.map_id,args[index])
    loc = thisevent.variable
    thisevent.moveto(loc[0],loc[1])
    thisevent.character_name = ""
  end
end

def getEventFromID(mapID,id)
  map = $MapFactory.getMap(mapID)
  return nil if !map
  return map.events[id]
end



#

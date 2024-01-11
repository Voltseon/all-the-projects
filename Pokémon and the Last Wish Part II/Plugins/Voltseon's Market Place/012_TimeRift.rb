def vStartRifting(eventID)
  event = get_character(eventID)
  newHue = event.character_hue + rand(10)
  newHue = 0 if newHue >= 255
  event.character_hue = newHue
  event.move_speed = rand(3)+1
end

def vPings(location)
  distance = Math::sqrt((($game_player.x-location[0]).abs**2) + (($game_player.y-location[1]).abs**2)).round
  pbSet(5,distance)
  if distance == 0
    vSSF(14)
  end
end

def vCheckPNThing
  mapData = Compiler::MapData.new
  amt = 0
  for id in mapData.mapinfos.keys.sort
    map = mapData.getMap(id)
    for event in map.events.values
      for page in event.pages
        list = page.list
        # Find all the trainer comments in the event
        for i in 0...list.length
          next if list[i].code!=101  # Comment (first line)
          command = list[i].parameters[0].clone
          for j in (i+1)...list.length
            break if list[j].code!=401   # Comment (continuation line)
            command += "\r\n"+list[j].parameters[0]
          end
          if command[/^(\\xn)/i]
            echoln _INTL("Change event {1} in {2} ID: {3}",event.id,pbGetMapNameFromId(id),id)
            echoln _INTL("Line: {1}",command)
            echoln _INTL("[{1},{2}]",event.x,event.y)
            echoln ""
            amt+=1
          end
        end
      end
    end
  end
  echoln amt
end
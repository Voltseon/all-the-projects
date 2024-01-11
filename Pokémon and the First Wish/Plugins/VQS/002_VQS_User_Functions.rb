def pbCheckAllQuestsForCompletion
  checks = pbGetAllUncompletedQuests
  checks.each do |quest|
    quest[1].trigger
  end
end

def pbGetAllUncompletedQuests
  ret = []
  $player.quests.each_with_index do |quest, i|
    next if quest.completed || !quest.active
    ret.push([i, quest])
  end
  return ret
end

def pbGetQuestByName(name)
  $player.quests.each do |quest|
    return quest if quest.name == name
  end
  return nil
end
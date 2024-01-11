def vqsGenerateRandomQuest
  evt = get_character(0)
  rewards = []
  rand(1..3).times { r = VQS_Config::randomized_reward.sample; rewards.push(r) unless rewards.any? { |a| a.include?(r[0]) } }
  rewards.sort! { |a,b| GameData::Item.get(a[0]).price <=> GameData::Item.get(b[0]).price || GameData::Item.get(a[0]).pocket <=> GameData::Item.get(b[0]).pocket }
  rand_index = rand(0...VQS_Config::randomized_container.length)
  container = VQS_Config::randomized_container[rand_index]
  progress_proc = VQS_Config::randomized_progress(container)[rand_index]
  clear_proc = VQS_Config::randomized_proc(container)[rand_index]
  name = VQS_Config::randomized_name(container)[rand_index]
  description = VQS_Config::randomized_description(container)[rand_index]
  request_npc = [evt.id, evt.map_id, evt.x, evt.y]
  location = nil
  new_quest = VQS_Quest.new(true, name, description, request_npc, location, rewards, container, clear_proc, progress_proc)
end
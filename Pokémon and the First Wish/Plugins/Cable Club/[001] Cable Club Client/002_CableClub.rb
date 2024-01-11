module CableClub
  def self.pokemon_order(client_id)
    case client_id
    when 0; [0, 1, 2, 3]
    when 1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.pokemon_target_order(client_id)
    case client_id
    when 0..1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.connect_to(msgwindow, partner_trainer_id)
    pbMessageDisplayDots(msgwindow, _INTL("Connecting"), 0)
    host,port = get_server_info
    Connection.open(host,port) do |connection|
      state = :await_server
      last_state = nil
      client_id = 0
      partner_name = nil
      partner_trainer_type = nil
      partner_party = nil
      frame = 0
      activity = nil
      seed = nil
      battle_type = nil
      chosen = nil
      partner_chosen = nil
      partner_confirm = false

      loop do
        if state != last_state
          last_state = state
          frame = 0
        else
          frame += 1
        end

        Graphics.update
        Input.update
        if Input.press?(Input::BACK)
          message = case state
            when :await_server; _INTL("Abort connection?\\^")
            when :await_partner; _INTL("Abort search?\\^")
            else; _INTL("Disconnect?\\^")
            end
          pbMessageDisplay(msgwindow, message)
          break if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
        end

        case state
        # Waiting to be connected to the server.
        # Note: does nothing without a non-blocking connection.
        when :await_server
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:find)
              writer.str(Settings::GAME_VERSION)
              writer.int(partner_trainer_id)
              writer.str($player.name)
              writer.int($player.id)
              writer.sym($player.online_trainer_type)
              write_party(writer)
            end
            state = :await_partner
          else
            pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nConnecting",$player.public_ID($player.id)), frame)
          end

        # Waiting to be connected to the partner.
        when :await_partner
          pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nSearching",$player.public_ID($player.id)), frame)
          connection.update do |record|
            case (type = record.sym)
            when :found
              client_id = record.int
              partner_name = record.str
              partner_trainer_type = record.sym
              partner_party = parse_party(record)
              pbMessageDisplay(msgwindow, _INTL("{1} {2} connected!",GameData::TrainerType.get(partner_trainer_type).name, partner_name))
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end

        # Choosing an activity (leader only).
        when :choose_activity
          pbMessageDisplay(msgwindow, _INTL("Choose an activity.\\^"))
          cmds = [_INTL("Single Battle"), _INTL("Double Battle"), _INTL("Trade")]
          cmds.push(_INTL("Mix Records")) if ENABLE_RECORD_MIXER
          command = pbShowCommands(msgwindow, cmds, -1)
          case command
          when 0..1 # Battle
            if command == 1 && $player.party_count < 2
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, you must have at least two Pokémon to engage in a double battle."))
            elsif command == 1 && partner_party.length < 2
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, your partner must have at least two Pokémon to engage in a double battle."))
            else
              connection.send do |writer|
                writer.sym(:battle)
                seed = rand(2**31)
                writer.int(seed)
                battle_type = case command
                  when 0; :single
                  when 1; :double
                  else; raise "Unknown battle type"
                  end
                writer.sym(battle_type)
              end
              activity = :battle
              state = :await_accept_activity
            end

          when 2 # Trade
            connection.send do |writer|
              writer.sym(:trade)
            end
            activity = :trade
            state = :await_accept_activity

          when 3 # Mix Records
            connection.send do |writer|
              writer.sym(:record_mix)
            end
            activity = :record_mix
            state = :await_accept_activity
            
          else # Cancel
            # TODO: Confirmation box?
            break
          end

        # Waiting for the partner to accept our activity (leader only).
        when :await_accept_activity
          pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to accept", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :ok
              case activity
              when :battle
                partner = NPCTrainer.new(partner_name, partner_trainer_type)
                (partner.partyID=0) rescue nil # EBDX compat
                do_battle(connection, client_id, seed, battle_type, partner, partner_party)
                state = :choose_activity

              when :trade
                chosen = choose_pokemon
                if chosen >= 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int(chosen)
                  end
                  state = :await_trade_confirm
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  connection.discard(1)
                  state = :choose_activity
                end

              when :record_mix
                do_mix_records(msgwindow,connection)
                state = :choose_activity
              
              else
                raise "Unknown activity: #{activity}"
              end

            when :cancel
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to #{activity.to_s}.", partner_name))
              state = :choose_activity

            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select an activity (follower only).
        when :await_choose_activity
          pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick an activity", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :battle
              seed = record.int
              battle_type = record.sym
              partner = NPCTrainer.new(partner_name, partner_trainer_type)
              (partner.partyID=0) rescue nil # EBDX compat
              # Auto-reject double battles that we cannot participate in.
              if battle_type == :double && $player.party_count < 2
                connection.send do |writer|
                  writer.sym(:cancel)
                end
                state = :await_choose_activity
              else
                pbMessageDisplay(msgwindow, _INTL("{1} wants to battle!\\^", partner_name))
                if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                  connection.send do |writer|
                    writer.sym(:ok)
                  end
                  do_battle(connection, client_id, seed, battle_type, partner, partner_party)
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  state = :await_choose_activity
                end
              end

            when :trade
              pbMessageDisplay(msgwindow, _INTL("{1} wants to trade!\\^", partner_name))
              if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                connection.send do |writer|
                  writer.sym(:ok)
                end
                chosen = choose_pokemon
                if chosen >= 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int(chosen)
                  end
                  state = :await_trade_confirm
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  connection.discard(1)
                  state = :await_choose_activity
                end
              else
                connection.send do |writer|
                  writer.sym(:cancel)
                end
                state = :await_choose_activity
              end

            when :record_mix
              pbMessageDisplay(msgwindow, _INTL("{1} wants to mix records!\\^", partner_name))
              if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                connection.send do |writer|
                  writer.sym(:ok)
                end
                do_mix_records(msgwindow,connection)
              else
                connection.send do |writer|
                  writer.sym(:cancel)
                end
              end
            
            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select a Pokémon to trade.
        when :await_trade_pokemon
          if partner_confirm
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to resynchronize", partner_name), frame)
          else
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner = NPCTrainer.new(partner_name, $player.trainer_type)
              $player.heal_party
              partner_party.each{|pkmn| pkmn.heal}
              pkmn = partner_party[partner_chosen]
              partner_party[partner_chosen] = $player.party[chosen]
              do_trade(chosen, partner, pkmn)
              connection.send do |writer|
                writer.sym(:update)
                write_pkmn(writer, $player.party[chosen])
              end
              partner_confirm = true

            when :update
              partner_party[partner_chosen] = parse_pkmn(record)
              partner_chosen = nil
              partner_confirm = false
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            when :cancel
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", partner_name))
              partner_chosen = nil
              partner_confirm = false
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end
        
        when :await_trade_confirm
          if partner_chosen.nil?
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick a Pokémon", partner_name), frame)
          else
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner_chosen = record.int
              $player.heal_party
              partner_party.each {|pkmn| pkmn.heal}
              partner_pkmn = partner_party[partner_chosen]
              your_pkmn = $player.party[chosen]
              abort=$player.able_pokemon_count==1 && your_pkmn==$player.able_party[0] && partner_pkmn.egg?
              able_party=partner_party.find_all { |p| p && !p.egg? && !p.fainted? }
              abort|=able_party.length==1 && partner_pkmn==able_party[0] && your_pkmn.egg?
              unless abort
                partner_speciesname = (partner_pkmn.egg?) ? _INTL("Egg") : partner_pkmn.speciesName
                your_speciesname = (your_pkmn.egg?) ? _INTL("Egg") : your_pkmn.speciesName
                loop do
                  pbMessageDisplay(msgwindow, _INTL("{1} has offered {2} ({3}) for your {4} ({5}).\\^",partner_name,
                      partner_pkmn.name,partner_speciesname,your_pkmn.name,your_speciesname))
                  command = pbShowCommands(msgwindow, [_INTL("Check {1}'s offer",partner_name), _INTL("Check My Offer"), _INTL("Accept/Deny Trade")], -1)
                  case command
                  when 0
                    check_pokemon(partner_pkmn)
                  when 1
                    check_pokemon(your_pkmn)
                  when 2
                    pbMessageDisplay(msgwindow, _INTL("Confirm the trade of {1} ({2}) for your {3} ({4}).\\^",partner_pkmn.name,partner_speciesname,
                        your_pkmn.name,your_speciesname))
                    if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                      connection.send do |writer|
                        writer.sym(:ok)
                      end
                      state = :await_trade_pokemon
                      break
                    else
                      connection.send do |writer|
                        writer.sym(:cancel)
                      end
                      partner_chosen = nil
                      connection.discard(1)
                      if client_id == 0
                        state = :choose_activity
                      else
                        state = :await_choose_activity
                      end
                      break
                    end
                  end
                end
              else
                pbMessageDisplay(msgwindow, _INTL("The trade was unable to be completed."))
                partner_chosen = nil
                if client_id == 0
                  state = :choose_activity
                else
                  state = :await_choose_activity
                end
              end
              
            when :cancel
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", partner_name))
              partner_chosen = nil
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end
        else
          raise "Unknown state: #{state}"
        end
      end
    connection.dispose
    end
  end

  def self.pbMessageDisplayDots(msgwindow, message, frame)
    pbMessageDisplay(msgwindow, message + "...".slice(0..(frame/8) % 3) + "\\^", false)
  end

  def self.do_battle(connection, client_id, seed, battle_type, partner, partner_party)
    $player.heal_party # Avoids having to transmit damaged state.
    partner_party.each{|pkmn| pkmn.heal} # back to back battles desync without it.
    scene = BattleCreationHelperMethods.create_battle_scene
    battle = Battle_CableClub.new(connection, client_id, scene, partner_party, partner)
    battle.items = []
    battle.internalBattle = false
    case battle_type
    when :single
      setBattleRule("single")
    when :double
      setBattleRule("double")
    else
      raise "Unknown battle type: #{battle_type}"
    end
    trainerbgm = pbGetTrainerBattleBGM(partner)
    EventHandlers.trigger(:on_start_battle)
    # XXX: Hope both battles take place in the same area for things like Nature Power.
    BattleCreationHelperMethods.prepare_battle(battle)
    $game_temp.clear_battle_rules
    exc = nil
    pbBattleAnimation(trainerbgm, (battle.singleBattle?) ? 1 : 3, [partner]) {
      pbSceneStandby {
        # XXX: Hope we call rand in the same order in both clients...
        srand(seed)
        begin
          battle.pbStartBattle
        rescue Connection::Disconnected
          scene.pbEndBattle(0)
          exc = $!
        end
      }
    }
    raise exc if exc
  end

  def self.do_trade(index, you, your_pkmn)
    my_pkmn = $player.party[index]
    $player.pokedex.register(your_pkmn)
    $player.pokedex.set_owned(your_pkmn.species)
    pbFadeOutInWithMusic(99999) {
      scene = PokemonTrade_Scene.new
      scene.pbStartScreen(my_pkmn, your_pkmn, $player.name, you.name)
      scene.pbTrade
      scene.pbEndScreen
    }
    $player.party[index] = your_pkmn
  end

  def self.choose_pokemon
    chosen = -1
    pbFadeOutIn(99999) {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      screen.pbStartScene(_INTL("Choose a Pokémon."), false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    }
    return chosen
  end
  
  def self.check_pokemon(pkmn)
    pbFadeOutIn(99999) {
      scene = PokemonSummary_Scene.new
      screen = PokemonSummaryScreen.new(scene)
      screen.pbStartScreen([pkmn],0)
    }
  end

  def self.write_party(writer)
    writer.int($player.party_count)
    $player.party.each do |pkmn|
      write_pkmn(writer, pkmn)
    end
  end

  def self.write_pkmn(writer, pkmn)
    writer.sym(pkmn.species)
    writer.int(pkmn.level)
    writer.int(pkmn.personalID)
    writer.int(pkmn.owner.id)
    writer.str(pkmn.owner.name)
    writer.int(pkmn.owner.gender)
    writer.int(pkmn.exp)
    writer.int(pkmn.form)
    writer.nil_or(:sym, pkmn.item_id)
    writer.int(pkmn.numMoves)
    pkmn.moves.each do |move|
      writer.sym(move.id)
      writer.int(move.ppup)
    end
    writer.int(pkmn.first_moves.length)
    pkmn.first_moves.each do |move|
      writer.sym(move)
    end
    writer.int(pkmn.gender)
    writer.nil_or(:bool,pkmn.shiny?)
    writer.nil_or(:sym, pkmn.ability_id)
    writer.nil_or(:int, pkmn.ability_index)
    writer.nil_or(:sym, pkmn.nature_id)
    writer.nil_or(:sym, pkmn.nature_for_stats_id)
    GameData::Stat.each_main do |s|
      writer.int(pkmn.iv[s.id])
      writer.nil_or(:bool, pkmn.ivMaxed[s.id])
      writer.int(pkmn.ev[s.id])
    end
    writer.int(pkmn.happiness)
    writer.str(pkmn.name)
    writer.sym(pkmn.poke_ball)
    writer.int(pkmn.steps_to_hatch)
    writer.int(pkmn.pokerus)
    writer.int(pkmn.obtain_method)
    writer.int(pkmn.obtain_map)
    writer.nil_or(:str,pkmn.obtain_text)
    writer.int(pkmn.obtain_level)
    writer.int(pkmn.hatched_map)
    writer.int(pkmn.cool)
    writer.int(pkmn.beauty)
    writer.int(pkmn.cute)
    writer.int(pkmn.smart)
    writer.int(pkmn.tough)
    writer.int(pkmn.sheen)
    writer.int(pkmn.numRibbons)
    pkmn.ribbons.each do |ribbon|
      writer.sym(ribbon)
    end
    writer.bool(!!pkmn.mail)
    if pkmn.mail
      writer.sym(pkmn.mail.item)
      writer.str(pkmn.mail.message)
      writer.str(pkmn.mail.sender)
      if pkmn.mail.poke1
        #[species,gender,shininess,form,shadowness,is egg]
        writer.sym(pkmn.mail.poke1[0])
        writer.int(pkmn.mail.poke1[1])
        writer.bool(pkmn.mail.poke1[2])
        writer.int(pkmn.mail.poke1[3])
        writer.bool(pkmn.mail.poke1[4])
        writer.bool(pkmn.mail.poke1[5])
      else
        writer.nil_or(:sym,nil)
      end
      if pkmn.mail.poke2
        #[species,gender,shininess,form,shadowness,is egg]
        writer.sym(pkmn.mail.poke2[0])
        writer.int(pkmn.mail.poke2[1])
        writer.bool(pkmn.mail.poke2[2])
        writer.int(pkmn.mail.poke2[3])
        writer.bool(pkmn.mail.poke2[4])
        writer.bool(pkmn.mail.poke2[5])
      else
        writer.nil_or(:sym,nil)
      end
      if pkmn.mail.poke3
        #[species,gender,shininess,form,shadowness,is egg]
        writer.sym(pkmn.mail.poke3[0])
        writer.int(pkmn.mail.poke3[1])
        writer.bool(pkmn.mail.poke3[2])
        writer.int(pkmn.mail.poke3[3])
        writer.bool(pkmn.mail.poke3[4])
        writer.bool(pkmn.mail.poke3[5])
      else
        writer.nil_or(:sym,nil)
      end
    end
    writer.bool(!!pkmn.fused)
    if pkmn.fused
      write_pkmn(writer, pkmn.fused)
    end
  end

  def self.parse_party(record)
    party = []
    record.int.times do
      party << parse_pkmn(record)
    end
    return party
  end

  def self.parse_pkmn(record)
    species = record.sym
    level = record.int
    pkmn = Pokemon.new(species, level, $player)
    pkmn.personalID = record.int
    pkmn.owner.id = record.int
    pkmn.owner.name = record.str
    pkmn.owner.gender = record.int
    pkmn.exp = record.int
    form = record.int
    #pkmn.forced_form = form if MultipleForms.hasFunction?(pkmn.species,"getForm")
    pkmn.form_simple = form
    pkmn.item = record.sym
    pkmn.forget_all_moves
    for i in 0...record.int
      pkmn.moves[i] = Pokemon::Move.new(record.sym)
      pkmn.moves[i].ppup = record.int
    end
    pkmn.moves.compact!
    pkmn.clear_first_moves
    for i in 0...record.int
      pkmn.add_first_move(record.sym)
    end
    pkmn.gender = record.int
    pkmn.shiny = record.nil_or(:bool)
    pkmn.ability = record.nil_or(:sym)
    pkmn.ability_index = record.nil_or(:int)
    pkmn.nature = record.sym
    pkmn.nature_for_stats = record.nil_or(:sym)
    GameData::Stat.each_main do |s|
      pkmn.iv[s.id] = record.int
      pkmn.ivMaxed[s.id] = record.nil_or(:bool)
      pkmn.ev[s.id] = record.int
    end
    pkmn.happiness = record.int
    pkmn.name = record.str
    pkmn.poke_ball = record.sym
    pkmn.steps_to_hatch = record.int
    pkmn.pokerus = record.int
    pkmn.obtain_method = record.int
    pkmn.obtain_map = record.int
    pkmn.obtain_text = record.nil_or(:str)
    pkmn.obtain_level = record.int
    pkmn.hatched_map = record.int
    pkmn.cool = record.int
    pkmn.beauty = record.int
    pkmn.cute = record.int
    pkmn.smart = record.int
    pkmn.tough = record.int
    pkmn.sheen = record.int
    for i in 0...record.int
      pkmn.giveRibbon(record.sym)
    end
    if record.bool() # mail
      m_item = record.sym()
      m_msg = record.str()
      m_sender = record.str()
      m_poke1 = []
      if m_species1 = record.nil_or(:sym)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke1[0] = m_species1
        m_poke1[1] = record.int()
        m_poke1[2] = record.bool()
        m_poke1[3] = record.int()
        m_poke1[4] = record.bool()
        m_poke1[5] = record.bool()
      else
        m_poke1 = nil
      end
      m_poke2 = []
      if m_species2 = record.nil_or(:sym)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke2[0] = m_species2
        m_poke2[1] = record.int()
        m_poke2[2] = record.bool()
        m_poke2[3] = record.int()
        m_poke2[4] = record.bool()
        m_poke2[5] = record.bool()
      else
        m_poke2 = nil
      end
      m_poke3 = []
      if m_species3 = record.nil_or(:sym)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke3[0] = m_species3
        m_poke3[1] = record.int()
        m_poke3[2] = record.bool()
        m_poke3[3] = record.int()
        m_poke3[4] = record.bool()
        m_poke3[5] = record.bool()
      else
        m_poke3 = nil
      end
      pkmn.mail = Mail.new(m_item,m_msg,m_sender,m_poke1,m_poke2,m_poke3)
    end
    if record.bool() # fused
      pkmn.fused = parse_pkmn(record)
    end
    pkmn.calc_stats
    return pkmn
  end
  
  def self.get_server_info
    ret = [HOST,PORT]
    if safeExists?("serverinfo.ini")
      File.foreach("serverinfo.ini") do |line|
        case line
        when /^\s*[Hh][Oo][Ss][Tt]\s*=\s*(.+)$/
          ret[0] = $1 if !nil_or_empty?($1)
        when /^\s*[Pp][Oo][Rr][Tt]\s*=\s*(\d{1,5})$/
          if !nil_or_empty?($1)
            port = $1.to_i
            ret[1] = port if port>0 && port<=65535
          end
        end
      end
    end
    return ret
  end
end
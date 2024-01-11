def vCableClub
  scene = CableClub_Scene.new
  screen = CableClub_Screen.new(scene)
  screen.pbStartScreen
end

class PokemonTemp
  attr_accessor :partner_data
  attr_accessor :cable_points_gained

  # name, trainer_type, id, outfit
  def partner_data
    @partner_data = [] if !@partner_data
    return @partner_data
  end

  # temporarily stores the cable points you gained
  def cable_points_gained
    @cable_points_gained = 0 if !@cable_points_gained
    return @cable_points_gained
  end
end

class CableClub_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbInputs
    @scene.pbEndScene
  end
end

class CableClub_Scene
  TEXTBASECOLOR    = Color.new(248,248,248)
  TEXTSHADOWCOLOR  = Color.new(36 ,44, 100)

  PATH = "Graphics/Pictures/CableClub/"

  # Initializes Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @index = 0
    @player_id = $Trainer.public_ID($Trainer.id)
    @player_name = $Trainer.name
    @connected = false
    @disposed = false
  end

  # draw scene elements
  def pbStartScene
    # Music
    pbBGMPlay("HGSS 240 Pokeathlon In the Pokeathlon Dome")
    # Background
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("%sbg",PATH))
    # Overlay
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Player icon
    player_filename = GameData::TrainerType.charset_filename($Trainer.trainer_type)
    @sprites["player_icon"] = AnimatedSprite.create(player_filename,4,3)
    @sprites["player_icon"].viewport = @viewport
    @sprites["player_icon"].x = 6
    @sprites["player_icon"].y = 6
    @sprites["player_icon"].src_rect = Rect.new(0,0,64,64)
    @sprites["player_icon"].play
    # Player id
    @sprites["player_id"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["player_id"].bitmap)
    pbDrawShadowText(@sprites["player_id"].bitmap,82,42,90,32,_ISPRINTF("{1:05d}",@player_id),TEXTBASECOLOR,TEXTSHADOWCOLOR)
    # Player name
    @sprites["player_name"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["player_name"].bitmap)
    pbDrawShadowText(@sprites["player_name"].bitmap,82,8,132,32,"#{@player_name}",TEXTBASECOLOR,TEXTSHADOWCOLOR)
    # Button connect
    @sprites["connect"] = ChangelingSprite.new(146,128,@viewport)
    @sprites["connect"].addBitmap("unsel",_INTL("{1}/button",PATH))
    @sprites["connect"].addBitmap("sel",_INTL("{1}/button_sel",PATH))
    @sprites["connect_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["connect_text"].bitmap)
    pbDrawShadowText(@sprites["connect_text"].bitmap,146,136,220,32,"Connect",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    # Button exit
    @sprites["exit"] = ChangelingSprite.new(146,192,@viewport)
    @sprites["exit"].addBitmap("unsel",_INTL("{1}/button",PATH))
    @sprites["exit"].addBitmap("sel",_INTL("{1}/button_sel",PATH))
    @sprites["exit_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["exit_text"].bitmap)
    pbDrawShadowText(@sprites["exit_text"].bitmap,146,200,220,32,"Exit",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    # Button trade
    @sprites["trade"] = ChangelingSprite.new(146,256,@viewport)
    @sprites["trade"].addBitmap("unsel",_INTL("{1}/button",PATH))
    @sprites["trade"].addBitmap("sel",_INTL("{1}/button_sel",PATH))
    @sprites["trade_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["trade_text"].bitmap)
    pbDrawShadowText(@sprites["trade_text"].bitmap,146,264,220,32,"Trade",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    # Button disconnect
    @sprites["disconnect"] = ChangelingSprite.new(146,320,@viewport)
    @sprites["disconnect"].addBitmap("unsel",_INTL("{1}/button",PATH))
    @sprites["disconnect"].addBitmap("sel",_INTL("{1}/button_sel",PATH))
    @sprites["disconnect_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["disconnect_text"].bitmap)
    pbDrawShadowText(@sprites["disconnect_text"].bitmap,146,328,220,32,"Disconnect",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    # Draw
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbInputs
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @disposed
        break
      else
        if Input.trigger?(Input::DOWN) && @index < 1
          pbPlayCursorSE
          @index += 1
          drawPresent
        elsif Input.trigger?(Input::UP) && @index > 0
          pbPlayCursorSE
          @index -= 1
          drawPresent
        elsif Input.trigger?(Input::USE)
          drawPresent
          if @index == 0
            pbPlayCursorSE
            pbCableClub(self)
            @partner_data = []
            @connected = false
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    end
  end

  def drawPresent
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Buttons
    @sprites["connect"].changeBitmap(@index==0 ? "sel" : "unsel")
    @sprites["exit"].changeBitmap(@index==1 ? "sel" : "unsel")
    @sprites["trade"].changeBitmap(@index==2 ? "sel" : "unsel")
    @sprites["disconnect"].changeBitmap(@index==3 ? "sel" : "unsel")
    @sprites["trade"].visible = @connected
    @sprites["trade_text"].visible = @connected
    @sprites["disconnect"].visible = @connected
    @sprites["disconnect_text"].visible = @connected
    # Connected texts
    @sprites["connect_text"].bitmap.clear
    @sprites["exit_text"].bitmap.clear
    connect_text = @connected ? "Single Battle" : "Connect"
    exit_text = @connected ? "Double Battle" : "Exit"
    pbDrawShadowText(@sprites["connect_text"].bitmap,146,136,220,32,connect_text,TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    pbDrawShadowText(@sprites["exit_text"].bitmap,146,200,220,32,exit_text,TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    # Partner stuffs
    if $PokemonTemp.partner_data != [] && !@sprites["partner_icon"]
      # Partner icon
      partner_trainer_type = $PokemonTemp.partner_data[1]
      outfit = $PokemonTemp.partner_data[3] == 0 ? "" : "_#{$PokemonTemp.partner_data[3]}"
      partner_filename = GameData::TrainerType.charset_filename(partner_trainer_type) + outfit
      @sprites["partner_icon"] = AnimatedSprite.create(partner_filename,4,3)
      @sprites["partner_icon"].viewport = @viewport
      @sprites["partner_icon"].x = 442
      @sprites["partner_icon"].y = 6
      @sprites["partner_icon"].src_rect = Rect.new(0,0,64,64)
      @sprites["partner_icon"].play
      # Partner id
      @sprites["partner_id"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
      pbSetSystemFont(@sprites["partner_id"].bitmap)
      pbDrawShadowText(@sprites["partner_id"].bitmap,334,40,90,32,"#{$PokemonTemp.partner_data[2]}",TEXTBASECOLOR,TEXTSHADOWCOLOR,2)
      # Partner name
      @sprites["partner_name"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
      pbSetSystemFont(@sprites["partner_name"].bitmap)
      pbDrawShadowText(@sprites["partner_name"].bitmap,292,6,132,32,"#{$PokemonTemp.partner_data[0]}",TEXTBASECOLOR,TEXTSHADOWCOLOR,2)
    end
  end

  def pbUpdate
    drawPresent if !@disposed
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @viewport.dispose
    $game_map.autoplay
  end

  def connect_to(msgwindow, partner_trainer_id)
    CableClub::pbMessageDisplayDots(msgwindow, _INTL("Connecting"), 0)
    host,port = CableClub::get_server_info
    Connection.open(host,port) do |connection|
      state = :await_server
      last_state = nil
      client_id = 0
      partner_name = nil
      partner_trainer_type = nil
      partner_outfit = nil
      partner_party = nil
      frame = 0
      activity = nil
      seed = nil
      battle_type = nil
      chosen = nil
      partner_chosen = nil
      partner_confirm = false

      loop do
        pbUpdate if !@disposed

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
          if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            pbDisposeMessageWindow(msgwindow)
            return
          end
        end

        case state
        # Waiting to be connected to the server.
        # Note: does nothing without a non-blocking connection.
        when :await_server
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:find)
              writer.int(partner_trainer_id)
              writer.str($Trainer.name)
              writer.int($Trainer.id)
              writer.sym($Trainer.online_trainer_type)
              writer.int($Trainer.outfit)
              CableClub::write_party(writer)
            end
            state = :await_partner
          else
            CableClub::pbMessageDisplayDots(msgwindow, _ISPRINTF("Connecting"), frame)
          end

        # Waiting to be connected to the partner.
        when :await_partner
          CableClub::pbMessageDisplayDots(msgwindow, _ISPRINTF("Searching"), frame)
          connection.update do |record|
            case (type = record.sym)
            when :found
              client_id = record.int
              partner_name = record.str
              partner_trainer_type = record.sym
              partner_outfit = record.int
              partner_party = CableClub::parse_party(record)
              pbMEPlay("HGSS 241 Pokeathlon Getting Changed")
              pbMessageDisplay(msgwindow, _INTL("{1} {2} connected!",GameData::TrainerType.get(partner_trainer_type).name, partner_name))
              $PokemonTemp.partner_data = [partner_name, partner_trainer_type, partner_trainer_id, partner_outfit]
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
          @connected = true
          pbDisposeMessageWindow(msgwindow)
          until Input.trigger?(Input::USE)
            drawPresent
            pbUpdate
            Graphics.update
            Input.update
            if Input.trigger?(Input::DOWN) && @index < 3
              pbPlayCursorSE
              @index += 1
              drawPresent
            elsif Input.trigger?(Input::UP) && @index > 0
              pbPlayCursorSE
              @index -= 1
              drawPresent
            end
          end
          msgwindow = pbCreateMessageWindow()
          command = @index
          case command
          when 0..1 # Battle
            pbPlayCursorSE
            if command == 1 && $Trainer.party_count < 2
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
              pbPlayCursorSE
              connection.send do |writer|
                writer.sym(:trade)
              end
              activity = :trade
              state = :await_accept_activity

            else # Cancel
              pbPlayCloseMenuSE
              connection.send do |writer|
                writer.sym(:cancel)
              end
              # TODO: Confirmation box?
              return
            end

        # Waiting for the partner to accept our activity (leader only).
        when :await_accept_activity
          CableClub::pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to accept", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :ok
              case activity
              when :battle
                partner = NPCTrainer.new(partner_name, partner_trainer_type)
                CableClub::do_battle(connection, client_id, seed, battle_type, partner, partner_party) == 1 ? $PokemonTemp.cable_points_gained += 5 : $PokemonTemp.cable_points_gained += 3
                state = :choose_activity

              when :trade
                chosen = CableClub::choose_pokemon
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
          CableClub::pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick an activity", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :battle
              seed = record.int
              battle_type = record.sym
              partner = NPCTrainer.new(partner_name, partner_trainer_type)
              # Auto-reject double battles that we cannot participate in.
              if battle_type == :double && $Trainer.party_count < 2
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
                  CableClub::do_battle(connection, client_id, seed, battle_type, partner, partner_party) == 1 ? $PokemonTemp.cable_points_gained += 5 : $PokemonTemp.cable_points_gained += 3
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
                chosen = CableClub::choose_pokemon
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

            when :cancel
              pbMessageDisplay(msgwindow, _INTL("{1} disconnected!\\^", partner_name))
              return
              
            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select a Pokémon to trade.
        when :await_trade_pokemon
          if partner_confirm
            CableClub::pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to resynchronize", partner_name), frame)
          else
            CableClub::pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner = NPCTrainer.new(partner_name, $Trainer.trainer_type)
              pbHealAll
              partner_party.each{|pkmn| pkmn.heal}
              pkmn = partner_party[partner_chosen]
              partner_party[partner_chosen] = $Trainer.party[chosen]
              CableClub::do_trade(chosen, partner, pkmn)
              connection.send do |writer|
                writer.sym(:update)
                CableClub::write_pkmn(writer, $Trainer.party[chosen])
              end
              $PokemonTemp.cable_points_gained += 1
              partner_confirm = true

            when :update
              partner_party[partner_chosen] = CableClub::parse_pkmn(record)
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
            CableClub::pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick a Pokémon", partner_name), frame)
          else
            CableClub::pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner_chosen = record.int
              pbHealAll
              partner_party.each {|pkmn| pkmn.heal}
              partner_pkmn = partner_party[partner_chosen]
              your_pkmn = $Trainer.party[chosen]
              abort=$Trainer.able_pokemon_count==1 && your_pkmn==$Trainer.able_party[0] && partner_pkmn.egg?
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
                    CableClub::check_pokemon(partner_pkmn)
                  when 1
                    CableClub::check_pokemon(your_pkmn)
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
end
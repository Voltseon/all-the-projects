#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
#
#===============================================================================
class Scene_Map
  attr_reader :spritesetGlobal
  attr_accessor :map_renderer

  def spriteset(map_id = -1)
    return @spritesets[map_id] if map_id > 0 && @spritesets[map_id]
    @spritesets.each_value do |i|
      return i if i.map == $game_map
    end
    return @spritesets.values[0]
  end

  def createSpritesets
    @active_hud = ActiveHud.new
    $game_player.transparent = $game_map.map_id == 1 || $Client_id > 3
    unless $game_map.map_id == 1
      Discord.update_activity({
        :large_image => "icon_big",
        :large_image_text => "Pivot",
        :details => "Playing as #{$player.character.name} | #{$game_map.name}",
        :state => ($game_temp.training ? "In Training" : "In a Match"),
        :party_size => ($Partners.length + 1),
        :party_max => ($game_temp.training ? 1 : 4),
        :start_timestamp => Time.now.to_i
      })
    end
    @map_renderer = TilemapRenderer.new(Spriteset_Map.viewport) if !@map_renderer || @map_renderer.disposed?
    @spritesetGlobal = Spriteset_Global.new if !@spritesetGlobal
    @spritesets = {}
    $map_factory.maps.each do |map|
      @spritesets[map.map_id] = Spriteset_Map.new(map)
    end
    $map_factory.setSceneStarted(self)
    pbGlobalFadeIn if $overlay&.faded_out?
    updateSpritesets(true)
  end

  def createSingleSpriteset(map)
    temp = $scene.spriteset.getAnimations
    @spritesets[map] = Spriteset_Map.new($map_factory.maps[map])
    $scene.spriteset.restoreAnimations(temp)
    $map_factory.setSceneStarted(self)
    updateSpritesets(true)
  end

  def disposeSpritesets
    @active_hud.pbEndScene if @active_hud
    return if !@spritesets
    @spritesets.each_key do |i|
      next if !@spritesets[i]
      @spritesets[i].dispose
      @spritesets[i] = nil
    end
    @spritesets.clear
    @spritesets = {}
  end

  def autofade(mapid)
    playingBGM = $game_system.playing_bgm
    playingBGS = $game_system.playing_bgs
    return if !playingBGM && !playingBGS
    map = load_data(sprintf("Data/Map%03d.rxdata", mapid))
    if playingBGM && map.autoplay_bgm
      if (PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + map.bgm.name + "_n") &&
         playingBGM.name != map.bgm.name + "_n") || playingBGM.name != map.bgm.name
        pbBGMFade(0.8)
      end
    end
    if playingBGS && map.autoplay_bgs && playingBGS.name != map.bgs.name
      pbBGMFade(0.8)
    end
    Graphics.frame_reset
  end

  def transfer_player(cancel_swimming = true)
    $game_temp.player_transferring = false
    pbCancelVehicles($game_temp.player_new_map_id, cancel_swimming)
    autofade($game_temp.player_new_map_id)
    pbBridgeOff
    @spritesetGlobal.playersprite.clearShadows
    if $game_map.map_id != $game_temp.player_new_map_id
      $map_factory.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    $game_player.turn_generic($game_temp.player_new_direction) unless $game_temp.player_new_direction == 0
    $game_player.straighten
    $game_temp.followers.map_transfer_followers
    $game_map.update
    disposeSpritesets
    RPG::Cache.clear
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end

  def call_menu
    $game_temp.menu_calling = false
    $scene.active_hud.pause_menu_showing = true
  end

  def call_debug
    $game_temp.debug_calling = false
    pbPlayDecisionSE
    $game_player.straighten
    pbFadeOutIn { pbDebugMenu }
  end

  def miniupdate
    $game_temp.in_mini_update = true
    loop do
      $game_player.update
      updateMaps
      $game_system.update
      $game_screen.update
      break unless $game_temp.player_transferring
      transfer_player(false)
      break if $game_temp.transition_processing
    end
    updateSpritesets
    $game_temp.in_mini_update = false
  end

  def updateMaps
    $map_factory.maps.each do |map|
      map.update
    end
    $map_factory.updateMaps(self)
  end

  def updateSpritesets(refresh = false)
    @spritesets = {} if !@spritesets
    $map_factory.maps.each do |map|
      @spritesets[map.map_id] = Spriteset_Map.new(map) if !@spritesets[map.map_id]
    end
    keys = @spritesets.keys.clone
    keys.each do |i|
      if $map_factory.hasMap?(i)
        @spritesets[i].update
      else
        @spritesets[i]&.dispose
        @spritesets[i] = nil
        @spritesets.delete(i)
      end
    end
    @spritesetGlobal.update
    pbDayNightTint(@map_renderer)
    @map_renderer.refresh if refresh
    @map_renderer.update
    EventHandlers.trigger(:on_frame_update)
  end

  def active_hud; @active_hud; end

  def update
    #CableClub.start_update
    loop do
      @active_hud.pbUpdate if @active_hud
      pbMapInterpreter.update
      $game_player.update
      updateMaps
      $game_system.update
      $game_screen.update
      break unless $game_temp.player_transferring
      transfer_player(false)
      break if $game_temp.transition_processing
    end
    #CableClub.resolve_update
    updateSpritesets
    if $game_temp.title_screen_calling
      $game_temp.title_screen_calling = false
      SaveData.mark_values_as_unloaded
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition
      else
        Graphics.transition(8, "Graphics/Transitions/" + $game_temp.transition_name)
      end
    end
    return if $game_temp.message_window_showing
    if !pbMapInterpreterRunning?
      if Input.trigger?(Input::USE)
        $game_temp.interact_calling = true
      elsif Input.press?(Input::F9)
        $game_temp.debug_calling = true if $DEBUG
=begin
      elsif Input::scroll_v != 0
        scroll = Input::scroll_v
        scroll = scroll.negative? ? -1 : 1
        zoom = scroll.negative? ? "out" : "in"
        if !$game_temp.background_zoom
          $game_temp.background_zoom = ZoomMap.new(1,1,"in")
        end
        oldZoom = $game_temp.background_zoom.instance_variable_get(:@sprites)["map"].zoom
        zoomAmount = ($PokemonSystem.screensize == 2) ? 1 : 0.5
        goal = oldZoom + (scroll*zoomAmount)
        goal = pbGet(26) if goal < pbGet(26)
        goal = 7 if goal > 7
        pbZoomMap(goal,0.3,zoom)
=end
      end
    end
    unless $game_player.moving? || $scene.active_hud&.aiming
      if $game_temp.menu_calling
        call_menu
      elsif $game_temp.debug_calling
        call_debug
      elsif $game_temp.interact_calling
        $game_temp.interact_calling = false
        $game_player.straighten
        EventHandlers.trigger(:on_player_interact)
      end
    end
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    disposeSpritesets
    if $game_temp.title_screen_calling
      Graphics.transition
      Graphics.freeze
    end
  end
end
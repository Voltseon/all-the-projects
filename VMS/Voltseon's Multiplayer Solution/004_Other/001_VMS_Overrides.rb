class Game_Temp
  attr_accessor :vms

  alias vms_initialize initialize

  def initialize
    Kernel.at_exit() { VMS.leave }
    vms_initialize
    @vms = {
      socket: nil,
      cluster: -1,
      players: {},
      time_since_last_message: 0,
      ping_stamp: 0,
      ping_log: [],
      state: [:idle, nil],
      seed: 0,
      battle_player: nil,
      online_variables: {}
    }
  end
end

module Graphics
  class << self
    alias vms_update update unless method_defined?(:vms_update)

    def update(update_vms = true)
      vms_update
      if update_vms && VMS.is_connected?
        # Update VMS
        VMS.update
        # Clear events if necessary
        VMS.clean_up_events
      end
    end
  end
end

class AnimationSprite < RPG::Sprite
  alias vms_initialize initialize unless private_method_defined?(:vms_initialize)
  def initialize(animID, map, tileX, tileY, viewport = nil, tinting = false, height = 3, owner = true)
    @owner = owner
    @animID = animID
    @tinting = tinting
    @height = height
    vms_initialize(animID, map, tileX, tileY, viewport, tinting, height)
  end

  def owner;        return @owner;         end
  def animID;       return @animID;        end
  def map_id;       return @map&.map_id;   end
  def tileX;        return @tileX;         end
  def tileY;        return @tileY;         end
  def tinting;      return @tinting;       end
  def height;       return @height;        end
end

module VMS
  def self.set_all_vms_events_through(through)
    return if !VMS.is_connected?
    return if through.nil?
    return if !through.is_a?(TrueClass) && !through.is_a?(FalseClass)
    return if $game_map.nil?
    $game_map.events.each_value do |event|
      next if event.nil?
      next if event.erased?
      next if event.name.nil?
      next if !event.name.include?("vms_player")
      next if event.through == through
      event.through = through
    end
  end
end

alias vms_pbEventCanReachPlayer? pbEventCanReachPlayer?
def pbEventCanReachPlayer?(event, player, distance)
  VMS.set_all_vms_events_through(true)
  ret = vms_pbEventCanReachPlayer?(event, player, distance)
  VMS.set_all_vms_events_through(VMS::THROUGH)
  return ret
end

class Interpreter
  alias vms_update update unless method_defined?(:vms_update)
  def update
    VMS.set_all_vms_events_through(true)
    vms_update
    VMS.set_all_vms_events_through(VMS::THROUGH)
  end
end

class Spriteset_Map
  def addUserAnimation(animID, x, y, tinting = false, height = 3, owner = true)
    sprite = AnimationSprite.new(animID, self.map, x, y, @@viewport1, tinting, height, owner)
    addUserSprite(sprite)
    return sprite
  end

  def getAnimationSprites
    anim_sprites = []
    @usersprites.each do |sprite|
      next if sprite.nil? || sprite.disposed? || !sprite.is_a?(AnimationSprite)
      next unless sprite.owner
      anim_sprites.push([sprite.animID, sprite.map_id, sprite.tileX, sprite.tileY, sprite.tinting, sprite.height])
    end
    return anim_sprites
  end

  def animationExists?(animID, tileX, tileY, tinting, height)
    @usersprites.each do |sprite|
      next if sprite.nil? || sprite.disposed? || !sprite.is_a?(AnimationSprite)
      return true if sprite.animID == animID && sprite.tileX == tileX && sprite.tileY == tileY && sprite.tinting == tinting && sprite.height == height
    end
    return false
  end
end

class Game_Character
  attr_accessor :jumping_on_spot

  def step_anime
    return @step_anime
  end

  def x=(value)
    @x = value
  end

  def y=(value)
    @y = value
  end

  def real_x=(value)
    @real_x = value
  end

  def real_y=(value)
    @real_y = value
  end

  def step_anime=(value)
    @step_anime = value
  end

  def turn_toward_location(x, y)
    sx = @x + (@width / 2.0) - x
    sy = @y - (@height / 2.0) - y
    return if sx == 0 && sy == 0
    if sx.abs > sy.abs
      (sx > 0) ? turn_left : turn_right
    else
      (sy > 0) ? turn_up : turn_down
    end
  end
end

class Game_Event
  def name=(value)
    @name = value
  end

  def erased?
    return @erased
  end

  alias vms_should_update? should_update? unless method_defined?(:vms_should_update?)
  def should_update?(recalc = false)
    return true if self.name.include?("vms_player") if self.name
    return vms_should_update?(recalc)
  end
end

class Game_Player
  
end

class Sprite_SurfBase
  alias vms_initialize initialize unless private_method_defined?(:vms_initialize)
  def initialize(parent_sprite, viewport = nil)
    @connection_player = nil
    if parent_sprite.character != $game_player && parent_sprite.character.name && parent_sprite.character.name&.include?("vms_player")
      id = (parent_sprite.character.name.gsub("vms_player_","")).to_i
      player = VMS.get_player(id)
      unless player.nil?
        @connection_player = player
      end
    end
    vms_initialize(parent_sprite, viewport)
  end

  def update
    return if disposed?
    surf_check = (@connection_player.nil? ? $PokemonGlobal.surfing : @connection_player&.surfing)
    dive_check = (@connection_player.nil? ? $PokemonGlobal.diving : @connection_player&.diving)
    surf_base_coords = (@connection_player.nil? ? $game_temp.surf_base_coords : @connection_player&.surf_base_coords)
    surf_base_coords = nil if surf_base_coords = [nil, nil]
    if !surf_check && !dive_check
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    return if !@sprite
    if surf_check
      @sprite.bitmap = @surfbitmap.bitmap
      cw = @cws
      ch = @chs
    elsif dive_check
      @sprite.bitmap = @divebitmap.bitmap
      cw = @cwd
      ch = @chd
    end
    sx = event.pattern_surf * cw
    sy = ((event.direction - 2) / 2) * ch
    @sprite.src_rect.set(sx, sy, cw, ch)
    if surf_base_coords
      spr_x = (((surf_base_coords[0] * Game_Map::REAL_RES_X) - event.map.display_x).to_f / Game_Map::X_SUBPIXELS).round
      spr_x += (Game_Map::TILE_WIDTH / 2)
      spr_x = ((spr_x - (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
      @sprite.x = spr_x
      spr_y = (((surf_base_coords[1] * Game_Map::REAL_RES_Y) - event.map.display_y).to_f / Game_Map::Y_SUBPIXELS).round
      spr_y += (Game_Map::TILE_HEIGHT / 2) + 16
      spr_y = ((spr_y - (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
      @sprite.y = spr_y
    else
      @sprite.x = @parent_sprite.x
      @sprite.y = @parent_sprite.y
    end
    @sprite.ox      = cw / 2
    @sprite.oy      = ch - 16   # Assume base needs offsetting
    @sprite.oy      -= event.bob_height
    @sprite.z       = event.screen_z(ch) - 1
    @sprite.zoom_x  = @parent_sprite.zoom_x
    @sprite.zoom_y  = @parent_sprite.zoom_y
    @sprite.tone    = @parent_sprite.tone
    @sprite.color   = @parent_sprite.color
    @sprite.opacity = @parent_sprite.opacity
  end
end

class Sprite_Character < RPG::Sprite
  alias vms_initialize initialize unless private_method_defined?(:vms_initialize)

  def initialize(viewport, character = nil)
    vms_initialize(viewport, character)
    if !@reflection && (!character || character == $game_player || (character.name[/reflection/i] rescue false) || (character.name && character.name[/vms_player_(\d+)$/i] rescue false))
      @reflection = Sprite_Reflection.new(self, viewport)
    end
    @surfbase = Sprite_SurfBase.new(self, viewport) if !@surfbase && (character == $game_player || (character.name && character.name[/vms_player_(\d+)$/i] rescue false))
    update
  end
end

module VMS
  class Player
    attr_accessor :is_new

    def party
      @party = VMS.update_party(self)
      return @party
    end
  end
end

class Trainer
  def able_pokemon_trade_count
    ret = 0
    @party.each { |p| ret += 1 if p && !p.egg? && !p.shadowPokemon? }
    return ret
  end
end

class PokemonPauseMenu
  alias vms_pbShowInfo pbShowInfo unless method_defined?(:vms_pbShowInfo)

  def pbShowInfo
    vms_pbShowInfo
    if VMS.is_connected? && VMS::SHOW_CLUSTER_ID_IN_PAUSE_MENU
      @scene.pbShowInfo(_INTL("Cluster ID: {1}", VMS.get_cluster_id))
    end
  end
end

module PBDebug
  class << self
    alias_method :vms_log, :log unless method_defined?(:vms_log)
  end

  def self.log(msg)
    VMS.update if VMS.is_connected?
    PBDebug.vms_log(msg)
  end
end

module Transitions
  class Transition_Base
    alias vms_update update unless method_defined?(:vms_update)

    def update
      VMS.update if VMS.is_connected? && !disposed?
      vms_update
    end
  end
end

module RPG
  class Sprite < ::Sprite
    def frame
      return @_animation_frame || 0
    end
  end
end

class Battle::Scene
  alias vms_pbUpdate pbUpdate unless method_defined?(:vms_pbUpdate)
  
  def pbUpdate(cw = nil)
    VMS.update if VMS.is_connected?
    vms_pbUpdate(cw)
  end
end

class PokemonRegionMap_Scene
  alias vms_pbUpdate pbUpdate unless method_defined?(:vms_pbUpdate)

  def pbUpdate
    vms_pbUpdate
    return unless VMS::SHOW_PLAYERS_ON_REGION_MAP
    return unless VMS.is_connected?
    players = VMS.get_players
    return if players.empty?
    @maps = {} if @maps.nil?
    player_meta = $game_map.metadata
    player_region = (player_meta) ? player_meta.town_map_position[0] : @region >= 0 ? @region : 0
    players.each do |player|
      next if player.id == $player.id
      map_metadata = GameData::MapMetadata.try_get(player.map_id)
      next if map_metadata.nil?
      position = map_metadata.town_map_position
      next if position.nil?
      next if player_region != position[0]
      @maps[player.map_id] = $map_factory.getMap(player.map_id) if @maps[player.map_id].nil?
      map = @maps[player.map_id]
      map_x   = position[1]
      map_y   = position[2]
      mapsize  = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        map_x += (player.x * sqwidth / map.width).floor if sqwidth > 1
        map_y += (player.y * sqheight / map.height).floor if sqheight > 1
      end
      if @sprites["vms_player_#{player.id}"].nil?
        @sprites["vms_player_#{player.id}"] = IconSprite.new(0,0,@viewport)
        @sprites["vms_player_#{player.id}"].setBitmap(GameData::TrainerType.player_map_icon_filename(player.trainer_type))
        @sprites["vms_player_#{player.id}"].z = @sprites["player"].z
      end
      @sprites["vms_player_#{player.id}"].x = point_x_to_screen_x(map_x)
      @sprites["vms_player_#{player.id}"].y = point_y_to_screen_y(map_y)
    end
  end
end

MenuHandlers.add(:pause_menu, :vms, {
  "name"      => VMS::MENU_NAME,
  "order"     => 45,
  "condition" => proc { VMS::ACCESSIBLE_PROC.call && VMS::ACCESSIBLE_FROM_PAUSE_MENU && !VMS.is_connected? },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    choices = ["Create cluster", "Join cluster", "Cancel"]
    choice = VMS.message(VMS::MENU_CHOICES_MESSAGE, choices)
    case choice
    when 0 # Create cluster
      VMS.join(rand(10000...99999))
    when 1 # Join cluster
      id = "0"
      loop do
        id = pbMessageFreeText(VMS::MENU_ENTER_CLUSTER_ID_MESSAGE, "", false, 5)
        if id.length != 5 || id.to_i.to_s != id
          VMS.message(VMS::MENU_INVALID_CLUSTER_MESSAGE)
        else
          break
        end
        if id.nil? || id.empty?
          menu.pbShowMenu
          menu.pbRefresh
          next false
        end
      end
      VMS.join(id.to_i)
      VMS.message(VMS::MENU_CLUSTER_NOT_FOUND_MESSAGE) if VMS.is_connected? && VMS.get_player_count == 1
    when 2 # Cancel
      menu.pbShowMenu
      menu.pbRefresh
      next false
    end
    menu.pbEndScene
    next true
  }
})

MenuHandlers.add(:pause_menu, :vms_disconnect, {
  "name"      => "Disconnect",
  "order"     => 45,
  "condition" => proc { VMS::ACCESSIBLE_PROC.call && VMS::ACCESSIBLE_FROM_PAUSE_MENU && VMS.is_connected? },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(VMS::DISCONNECT_CONFIRMATION_MESSAGE)
      VMS.leave
      menu.pbEndScene
      next true
    end
    menu.pbShowMenu
    menu.pbRefresh
    next false
  }
})
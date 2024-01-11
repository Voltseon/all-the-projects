$room_id = 0

class RoomUI
  PATH = "Graphics/Pictures/Rooms/"
  BASE_COLOR = Color.new(248,248,248)
  SHADOW_COLOR = Color.new(64,64,64)
  def initialize
    @viewport = nil
    @sprites = {}
    @disposed = false
    @screen = 0
    @room_return = nil
    @frame = 0
    @my_partners = []
    @room_id = nil
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlay.z = 99999
    pbSetSmallFont(@overlay.bitmap)
    @sprites["bg"] = IconSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["bg"].setBitmap(PATH + "bg")
    @sprites["join_room"] = ButtonSprite.new( self,
                                              "Join Room",
                                              "Graphics/Pictures/Active HUD/pause_bg",
                                              "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                              proc { self.pbJoin },
                                              Graphics.width/2-64, 128, @viewport)
    @sprites["create_room"] = ButtonSprite.new( self,
                                                "Create Room",
                                                "Graphics/Pictures/Active HUD/pause_bg",
                                                "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                                proc { self.pbCreate },
                                                Graphics.width/2-64, 192, @viewport)
    @sprites["list_room"] = ButtonSprite.new( self,
                                              "Room List",
                                              "Graphics/Pictures/Active HUD/pause_bg",
                                              "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                              proc { self.screen = 2 },
                                              Graphics.width/2-64, 256, @viewport)
    @sprites["exit"] = ButtonSprite.new(self,
                                        "Exit",
                                        "Graphics/Pictures/Active HUD/pause_bg",
                                        "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                        proc { self.screen == 2 ? self.screen = 0 : self.pbEndScene },
                                        Graphics.width/2-64, 320, @viewport)
    @sprites["start_room"] = ButtonSprite.new(self,
                                              "Start",
                                              "Graphics/Pictures/Active HUD/pause_bg",
                                              "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                              proc { pbWebRequest({:ROOM_ID => @room_id, :ROOM_METHOD => "Delete"})  },
                                              Graphics.width/2-64, 192, @viewport)
    @sprites["leave_room"] = ButtonSprite.new(self,
                                              "Leave Room",
                                              "Graphics/Pictures/Active HUD/pause_bg",
                                              "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                              proc { self.screen = 0; pbWebRequest({:ROOM_ID => @room_id, :ROOM_METHOD => "Leave"})  },
                                              Graphics.width/2-64, 256, @viewport)                                              
    pbMain
  end

  def pbUpdate
    return if @disposed
    $room_id = @room_id
    Graphics.update
    Input.update
    @overlay.bitmap.clear
    textpos = []

    @sprites["join_room"].visible = @screen == 0
    @sprites["create_room"].visible = @screen == 0
    @sprites["list_room"].visible = @screen == 0
    @sprites["start_room"].visible = @screen == 1 && $Client_id == 0
    @sprites["leave_room"].visible = @screen == 1
    @sprites["exit"].visible = @screen == 0 || @screen == 2

    if @screen == 0 # Home
      
    elsif @screen == 1 # In a Room
      pbInRoom
      textpos.push([$player.name,Graphics.width/2,128+48*$Client_id,2,BASE_COLOR,SHADOW_COLOR])
      @my_partners.each_with_index do |partner, i|
        textpos.push([partner[1],Graphics.width/2,128+48*i,2,BASE_COLOR,SHADOW_COLOR])
      end
      textpos.push([@room_id.to_s,Graphics.width/2,64,2,BASE_COLOR,SHADOW_COLOR])
    elsif @screen == 2 # Room listing

    end
    pbDrawTextPositions(@overlay.bitmap, textpos) unless @disposed
    pbUpdateSpriteHash(@sprites) unless @disposed
  end

  def pbMain
    loop do
      break if @disposed
      pbUpdate
    end
  end

  def pbCreate
    @room_id = rand(10000..99999)
    check_valid = pbWebRequest({:ROOM_ID => @room_id, :ROOM_METHOD => "Check"})
    if !check_valid.include?("Empty room")
      pbCreate
      return
    end
    ret = pbWebRequest({:ROOM_ID => @room_id, :ROOM_METHOD => "Create"})
    if ret == "made"
      $Client_id = 0
      pbJoin(@room_id)
    else
      pbMessage("Something went wrong with creating the room...")
    end
  end

  def pbJoin(roomId=nil)
    if roomId.nil?
      params = ChooseNumberParams.new
      params.setRange(10000, 99999)
      params.setDefaultValue(10000)
      params.setCancelValue(-1)
      roomId = pbMessageChooseNumber(_INTL("Enter room code."), params)
    end
    if roomId >= 0
      if roomId < 10000 || roomId.nil?
        pbMessage("Room #{roomId} is not available!")
        @screen = 0
        return
      end
      check_valid = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Check"})
      if check_valid.include?("#{$player.public_ID($player.id)}")
        pbMessage("Room #{roomId} is not available!")
        @screen = 0
        return
      end
      @room_return = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Join"})
      if @room_return == "joined"
        @room_id = roomId
        @frame = 0
        @my_partners = []
        @screen = 1
      else
        pbMessage("Something went wrong with joining room #{@room_id}")
      end
    end
  end

  def pbInRoom
    if @room_return
      if @room_return.include?('&^#')
        partners = @room_return.split('&^*#@')
        partners.each do |prt|
          next if prt.nil?
          partner = prt.split('&^#')
          next if @my_partners.any? { |a| a.include?(partner[1].to_i) }
          if partner[1].to_i == $player.public_ID($player.id)
            $Client_id = partner[0].to_i-1
            next
          end
          @my_partners.push([partner[1].rjust(5, '0').to_i, partner[2].to_s])
        end
      end
    end
    if @frame%60==0
      @room_return = pbWebRequest({:ROOM_ID => @room_id, :ROOM_METHOD => "Check"})
    end
    @frame += 1
    if @room_return == "Empty room" && @screen == 1
      $Connections = []
      if @my_partners.empty?
        @screen = 0
        pbMessage("Something went wrong")
        return
      end
      @my_partners.each do |prtnr|
        CableClub::session(nil, prtnr[0])
      end
      @screen = 0
      pbEndScene
    end
  end

  def screen=(value)
    @screen = value
  end
  def screen; @screen; end

  def pbEndScene
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay&.dispose
    @background&.dispose
    @viewport&.dispose
  end
end
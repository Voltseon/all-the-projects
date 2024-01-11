class MakeHealingBallGraphics

  def initialize
    balls=[]
    for poke in $player.party
      balls.push(poke.poke_ball) if !poke.egg? #balls.push(poke.ballused) if !poke.isEgg?
    end
    return false if balls.length==0
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=999999
    for i in 0...balls.length
      @sprites["ball#{i}"]=Sprite.new(@viewport)
      if pbResolveBitmap("Graphics/Pictures/Balls/ball_#{balls[i]}.png")
        @sprites["ball#{i}"].bitmap=Bitmap.new("Graphics/Pictures/Balls/ball_#{balls[i]}.png")
      else
        @sprites["ball#{i}"].bitmap=Bitmap.new("Graphics/Pictures/Balls/ball_0.png")
      end
      @sprites["ball#{i}"].visible=false
    end
    offsetX = 0
    offsetY = -2
    bitmap1=Bitmap.new(256,192)
    bitmap2=Bitmap.new(256,192)
    rect1=Rect.new(0,0,256,192/4)
    for i in 0...balls.length
      case i
      when 0
        bitmap1.blt(36+offsetX,50+offsetY,@sprites["ball#{0}"].bitmap,rect1)
      when 1
        bitmap2.blt(36+offsetX,50+offsetY,@sprites["ball#{0}"].bitmap,rect1)
        bitmap2.blt(48+offsetX,50+offsetY,@sprites["ball#{1}"].bitmap,rect1)
      when 2
        bitmap1.blt(36+offsetX,98+offsetY,@sprites["ball#{0}"].bitmap,rect1)
        bitmap1.blt(48+offsetX,98+offsetY,@sprites["ball#{1}"].bitmap,rect1)
        bitmap1.blt(36+offsetX,106+offsetY,@sprites["ball#{2}"].bitmap,rect1)
      when 3
		    bitmap2.blt(36+offsetX,98+offsetY,@sprites["ball#{0}"].bitmap,rect1)
        bitmap2.blt(48+offsetX,98+offsetY,@sprites["ball#{1}"].bitmap,rect1)
        bitmap2.blt(36+offsetX,106+offsetY,@sprites["ball#{2}"].bitmap,rect1)
        bitmap2.blt(48+offsetX,106+offsetY,@sprites["ball#{3}"].bitmap,rect1)
      when 4
        bitmap1.blt(36+offsetX,146+offsetY,@sprites["ball#{0}"].bitmap,rect1)
        bitmap1.blt(48+offsetX,146+offsetY,@sprites["ball#{1}"].bitmap,rect1)
        bitmap1.blt(36+offsetX,154+offsetY,@sprites["ball#{2}"].bitmap,rect1)
        bitmap1.blt(48+offsetX,154+offsetY,@sprites["ball#{3}"].bitmap,rect1)
        bitmap1.blt(36+offsetX,162+offsetY,@sprites["ball#{4}"].bitmap,rect1)
      when 5
        bitmap2.blt(36+offsetX,146+offsetY,@sprites["ball#{0}"].bitmap,rect1)
        bitmap2.blt(48+offsetX,146+offsetY,@sprites["ball#{1}"].bitmap,rect1)
        bitmap2.blt(36+offsetX,154+offsetY,@sprites["ball#{2}"].bitmap,rect1)
        bitmap2.blt(48+offsetX,154+offsetY,@sprites["ball#{3}"].bitmap,rect1)
        bitmap2.blt(36+offsetX,162+offsetY,@sprites["ball#{4}"].bitmap,rect1)
        bitmap2.blt(48+offsetX,162+offsetY,@sprites["ball#{5}"].bitmap,rect1)
      end
      Graphics.update
    end
    if RTP.exists?("Graphics/Characters/Healing balls 1.png")
      File.delete("Graphics/Characters/Healing balls 1.png")
    end
    if RTP.exists?("Graphics/Characters/Healing balls 2")
      File.delete("Graphics/Characters/Healing balls 2")
    end
    bitmap1.to_file("Graphics/Characters/Healing balls 1.png")
    bitmap2.to_file("Graphics/Characters/Healing balls 2.png")
    RPG::Cache.retain("Graphics/Characters/Healing balls 1.png")
    RPG::Cache.retain("Graphics/Characters/Healing balls 2.png")
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    bitmap1.dispose
    bitmap2.dispose
  end
end

def fixBalls
  GameData::Item.each do |item|
    next unless item.is_poke_ball?
    fixBall(item.id.to_s)
  end
  fixBall
end

def fixBall(name="0")
  return unless pbResolveBitmap("Graphics/Pictures/Balls/ball_#{name}.png")
  bmp = Bitmap.new("Graphics/Pictures/Balls/ball_#{name}.png")
  bmp.blt(64, 0, bmp, Rect.new(128, 0, 128, 12))
  base = Bitmap.new(12,12)
  12.times do |x|
    12.times do |y|
      color = averageColor(bmp.get_pixel(x, y), bmp.get_pixel(192 + x, y))
      bmp.set_pixel(192 + x, y, color)
    end
  end
  bmp.blt(0, 192, base, Rect.new(0, 0, 12, 12), 200)
  bmp.to_file("Graphics/Pictures/Balls/ball_#{name}.png")
end

def averageColor(color1, color2)
  r = (color1.red + color2.red) / 2
  g = (color1.green + color2.green) / 2
  b = (color1.blue + color2.blue) / 2
  a = (color1.alpha + color2.alpha) / 2
  return Color.new(r, g, b, a)
end
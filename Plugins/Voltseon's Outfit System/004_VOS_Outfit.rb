# The entire outfit of the player
class Vosoutfit
  attr_accessor :hat
  attr_accessor :accessory
  attr_accessor :hair
  attr_accessor :undershirt
  attr_accessor :shirt
  attr_accessor :pants
  attr_accessor :shoes
  attr_accessor :extra

  # Returns a valid suffix
  def self.get_suffix(path)
    outfit = VOS_SEPERATE_BY_BUILTIN_OUTFITS ? "_#{$player.outfit}" : ""
    gender = VOS_SEPERATE_BY_GENDER ? "_#{$player.gender}" : ""
    ret = ""
    if VOS_SEPERATE_BY_STATES
      if $PokemonGlobal&.diving
        if VOS_USE_SURF_IF_NO_DIVE && Vosoutfit.try_resolve(path,outfit,gender,VOS_STATE_SUFFIXES[3]) == ""
          ret = "_#{VOS_STATE_SUFFIXES[1]}"
        else
          ret = "_#{VOS_STATE_SUFFIXES[3]}"
        end
      elsif $PokemonGlobal&.surfing
        ret = "_#{VOS_STATE_SUFFIXES[1]}"
      elsif $PokemonGlobal&.bicycle
        ret = "_#{VOS_STATE_SUFFIXES[2]}"
      elsif$PokemonGlobal&.fishing
        ret = "_#{VOS_STATE_SUFFIXES[4]}"
      elsif $game_player.can_run?
        ret = "_#{VOS_STATE_SUFFIXES[0]}"
      end
    end
    return Vosoutfit.try_resolve(path,outfit,gender,ret)
  end

  def self.try_resolve(path,outfit,gender,ret)
    val = ""
    ["",outfit].each do |out|
      ["",gender].each do |gen|
        ["",ret].each do |r|
          val = "#{out}#{gen}#{r}" if pbResolveBitmap(sprintf("%s%s%s%s",path,out,gen,r))
        end
      end
    end
    return val
  end

  def initialize
    @hat = Vosclothing.new
    @accessory = Vosclothing.new
    @hair = Vosclothing.new
    @undershirt = Vosclothing.new
    @shirt = Vosclothing.new
    @pants = Vosclothing.new
    @shoes = Vosclothing.new
    @extra = Vosclothing.new
  end

  def hat; @hat; end
  def accessory; @accessory; end
  def hair; @hair; end
  def undershirt; @undershirt; end
  def shirt; @shirt; end
  def pants; @pants; end
  def shoes; @shoes; end
  def extra; @extra; end

  def hat=(value); @hat = value; end
  def accessory=(value); @accessory = value; end
  def hair=(value); @hair = value; end
  def undershirt=(value); @undershirt = value; end
  def shirt=(value); @shirt = value; end
  def pants=(value); @pants = value; end
  def shoes=(value); @shoes = value; end
  def extra=(value); @extra = value; end

  # Get the piece of clothing from a name
  def get(value)
    case value
    when "hat" then @hat
    when "accessory" then @accessory
    when "hair" then @hair
    when "undershirt" then @undershirt
    when "shirt" then @shirt
    when "pants" then @pants
    when "shoes" then @shoes
    when "extra" then @extra
    end
  end

  # Set the piece of clothing from a name
  def set(value, setter)
    case value
    when "hat" then @hat = setter
    when "accessory" then @accessory = setter
    when "hair" then @hair = setter
    when "undershirt" then @undershirt = setter
    when "shirt" then @shirt = setter
    when "pants" then @pants = setter
    when "shoes" then @shoes = setter
    when "extra" then @extra = setter
    end
  end

  # Return the outfit as an array
  def retall
    return [["hat", @hat], ["accessory", @accessory], ["hair", @hair], ["undershirt", @undershirt], ["shirt", @shirt], ["pants", @pants], ["shoes", @shoes], ["extra", @extra]]
  end
end
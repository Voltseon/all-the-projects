# A singular piece of clothing
class Vosclothing
  attr_accessor :id
  attr_accessor :name
  attr_accessor :hue
  attr_accessor :visible

  def initialize(id=-1, name="#{id}", hue=0, visible=true)
    @id = id
    @name = name
    @hue = hue
    @visible = visible
  end

  def id; @id; end
  def name; @name; end
  def hue; @hue; end
  def visible; @visible; end

  def id=(value); @id = value; end
  def name=(value); @name = value; end
  def hue=(value); @hue = value; end
  def visible=(value); @visible = value; end
end
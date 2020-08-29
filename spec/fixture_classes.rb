require_relative '../src/implicitly'

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    self.x = x
    self.y = y
  end

end

class Canvas

  def draw_point(point)
    20
  end

  types_of :draw_point do
    param :point, Point
  end

  def draw_circle(point, radius)
    radius
  end

  types_of :draw_circle do
    param :point, Point
    param :radius, Fixnum
  end

end
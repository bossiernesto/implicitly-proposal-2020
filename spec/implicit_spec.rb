require 'rspec'
require_relative '../src/implicitly'

describe 'Test implicit infraestructure' do

  before(:each) do
    require_relative 'fixture_classes'
    @canvas = Canvas.new
    @implicit = Implicit.new
    @implicit.for_class Canvas
    @implicit.condition = lambda { |*params|
      params[0].is_a? Fixnum and params[1].is_a? Fixnum
    }
    @implicit.conversion = lambda { |*params|
      [Point.new(params[0], params[1])] +params[2..-1]
    }

    Implicits.add @implicit

  end

  it 'Valid call to draw_circle with no implicit call' do
    @canvas.draw_circle(Point.new(123, 4), 23).should eq(23)
  end

  it 'Valid call that matches implicit' do
    @canvas.draw_circle(123, 4, 23).should eq(23)
  end

  it 'invalid call that doesn\'t match implicit' do
    expect { @canvas.draw_circle(Point.new(23, 2), 'Hello World') }.to raise_exception
  end

  it 'invalid call that after adding the implicit will ' do
    Implicits.clean_implicits
    expect { @canvas.draw_circle(123, 12, 34) }.to raise_exception
    Implicits.add @implicit

    @canvas.draw_circle(123, 12, 34).should eq(34)
  end

end
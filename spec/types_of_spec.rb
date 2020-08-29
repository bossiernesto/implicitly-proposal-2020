require 'rspec'
require_relative '../src/implicitly'


describe 'checking types for Ruby classes' do

  before(:each) do
    require_relative 'fixture_classes'
    @canvas = Canvas.new
  end

  it 'incorrect type entered as parameters' do
    expect { @canvas.draw_point(34) }.to raise_exception
  end

  it 'correct type entered as parameters' do
    @canvas.draw_point(Point.new(30, 15)).should eq(20)
  end

  it 'incorrect type entered as parameters' do
    expect { @canvas.draw_circle(23, 45) }.to raise_exception
  end

  it 'incorrect second type parameters' do
    expect { @canvas.draw_circle(Point.new(1, 4), 'P') }.to raise_exception
  end

  it 'correct types entered as parameters' do
    @canvas.draw_circle(Point.new(24, 13), 34).should eq(34)
  end

  it 'incorrect number of parameters' do
    expect { @canvas.draw_circle(Point.new(12, 3)).should eq(34) }.to raise_exception
  end

end
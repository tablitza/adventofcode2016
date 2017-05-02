#!/usr/bin/env ruby
class Position
  (fields = [:heading,:x,:y]).each { |v| attr_accessor v }
  define_method :initialize do |*args|
    fields.zip(args) { |f,a| send "#{f}=",a } end

  def self.initial; new :north,0,0 end
  def with; instance_eval &proc; self end
  def self.advance *args
    return method(__method__) if args.empty?
    prev, (turn,stride) = args
    Position.new.with do
      @heading = case [prev.heading,turn.to_sym]
                 when [:north,:L],[:south,:R] then @x = prev.x - stride
                   :west
                 when [:north,:R],[:south,:L] then @x = prev.x + stride
                   :east
                 when [:east,:L],[:west,:R] then @y = prev.y + stride
                   :north
                 when [:east,:R],[:west,:L] then @y = prev.y - stride
                   :south
                 end
      @x ||= prev.x
      @y ||= prev.y
    end end
end

File.read("inputs/1.inp")
  .split(",")
  .map do |instr|
    turn,*stride = instr.lstrip.chars
    [turn, stride.join.to_i]
  end
  .reduce(Position.initial, &Position.advance)
  .with { p x.abs + y.abs }

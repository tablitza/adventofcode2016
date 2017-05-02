#!/usr/bin/env ruby
require 'set'

class Enumerator::Lazy
  def reduce *arg,&blk
    arg.last.respond_to?(:to_sym) and sym = arg.pop
    blk ||= proc { |memo,v| memo.send(sym,v) }
    memo = unless arg.empty? then arg.first
           else self.next end
    stream = Enumerator.new { |y|
      loop { y << self.next } }
    Enumerator::Lazy.new(stream) do |yielder,nxt|
      memo = blk.call(memo,nxt)
      yielder << memo
    end
  end
end

class Position
  (fields = [:heading,:x,:y,:trail,:crossover]).each { |v| attr_accessor v }
  define_method :initialize do |*args|
    fields.zip(args) { |f,a| send "#{f}=",a } end

  def self.initial; new :north,0,0 end
  def with; instance_eval &proc; self end
  def self.advance *args
    return method(__method__) if args.empty?
    prev, (turn,stride) = args
    Position.new.with do
        @heading,
        @trail =
          case [prev.heading,turn.to_sym]
          when [:north,:L],[:south,:R] then @x = prev.x - stride
            [:west,
             [*@x..prev.x].product([prev.y]).reverse]
          when [:north,:R],[:south,:L] then @x = prev.x + stride
            [:east,
             [*prev.x..@x].product([prev.y])]
          when [:east,:L],[:west,:R] then @y = prev.y + stride
            [:north,
             [prev.x].product([*prev.y..@y])]
          when [:east,:R],[:west,:L] then @y = prev.y - stride
            [:south,
             [prev.x].product([*@y..prev.y]).reverse]
          end.tap { |_,trail| trail.shift }
        @x ||= prev.x
        @y ||= prev.y
    end
  end
  def to_a; [ [x,y] ] end
end

seen = Set[*Position.initial]
File.read("inputs/1.inp")
  .split(",")
  .map do |instr|
    turn,*stride = instr.lstrip.chars
    [turn, stride.join.to_i]
  end
  .lazy.reduce(Position.initial, &Position.advance)
  .detect do |leap|
    leap.trail.any? { |v| leap.crossover = v if seen.member?(v) } or !seen.merge leap.trail
  end
  .with { p crossover.first.abs + crossover.last.abs }

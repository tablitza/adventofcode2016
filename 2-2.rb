#!/usr/bin/env ruby
board = %{
0000000
0001000
0023400
0567890
00ABC00
000D000
0000000
}

$kpad = board.strip.split.map &:chars

Point = Struct.new :x,:y do
  def U
    case $kpad[x-1][y]
    when "0" then self
    else Point[x-1,y]
    end
  end
  
  def D
    case $kpad[x+1][y]
    when "0" then self
    else Point[x+1,y]
    end
  end
  
  def L
    case $kpad[x][y-1]
    when "0" then self
    else Point[x,y-1]
    end
  end
  
  def R
    case $kpad[x][y+1]
    when "0" then self
    else Point[x,y+1]
    end
  end

  def self.initial() new(3,1) end
  def self.advance *args
    return method(__method__) if args.empty?
    memo, nxt_sym = args
    memo.send nxt_sym
  end
end

p (File.read("inputs/2.inp")
  .split.map(&:chars)
  .map do |instr|
    instr.reduce(Point.initial, &Point.advance)
  end
  .map do |press|
    $kpad[press.x][press.y]
  end.join)

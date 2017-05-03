#!/usr/bin/env ruby
Point = Struct.new :row, :col do
  Bottom,Left = 1,1
  Top,Right = 3,3
  def self.[](_row,_col)
    p = new _row,_col
    case _row
    when Bottom then p.nothing_for :D
    when Top then p.nothing_for :U
    end
    case _col
    when Left then p.nothing_for :L
    when Right then p.nothing_for :R
    end
    p
  end
  def nothing_for name
    define_singleton_method(name) { itself }
  end

  def U; Point[row+1,col] end
  
  def D; Point[row-1,col] end
  
  def L; Point[row,col-1] end
  
  def R; Point[row,col+1] end

  def self.initial; new(2,2) end
  def self.advance *args
    return method(__method__) if args.empty?
    memo, nxt_sym = args
    memo.send nxt_sym
  end
end

keypad = [ 7..9, 4..6, 1..3 ].map &:entries
p (File.read("inputs/2.inp")
  .split.map(&:chars)
  .map do |instr|
    row, col = *instr.reduce(Point.initial, &Point.advance)
    keypad.dig row-1,col-1
  end.join)

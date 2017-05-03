#!/usr/bin/env ruby
p (File.open("inputs/3.inp")
  .each_line.count do |nxt_triple|
    one,two,three = nxt_triple.split.map(&:to_i).sort
    one + two > three
  end)

#!/usr/bin/env ruby
p (File.open("inputs/3.inp")
  .each_line.each_slice(3).reduce(0) do |total, lines3|
    in_slice = lines3
      .map(&:split)
      .transpose
      .count do |nxt_tri|
        one,two,three = nxt_tri.map(&:to_i).sort
        one + two > three
      end
    total + in_slice
  end)

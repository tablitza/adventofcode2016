#!/usr/bin/env ruby
p (File.read("inputs/6.inp")
  .split.map(&:chars)
  .transpose
  .map do |col|
    col.uniq.min_by { |c| col.count c }
  end.join)


#!/usr/bin/env ruby
p (File.open("inputs/4.inp").each_line.inject(0) do |sum, line|
  code, sector, chksum = line.match(/\A([a-z\-]+)-(\d{3})\[([a-z]+)\]\Z/).captures
  computed_checksum =
    code.chars
    .reject { |e| e == "-" }
    .group_by(&:itself)
    .map { |k,v| [v.size, k] }
    .sort_by { |repeat,char| [-repeat,char] }
    .take(5)
    .map(&:last)
    .join
  if chksum == computed_checksum then sum + sector.to_i
  else sum end
  end)

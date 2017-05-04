#!/usr/bin/env ruby
Alphabet = [*'a'..'z']
File.open("inputs/4.inp").each_line.detect do |line|
  code, sector, chksum = line.match(/\A([a-z\-]+)-(\d{3})\[([a-z]+)\]\Z/).captures
  computed_checksum =
    code.chars
    .reject { |e| e == "-" }
    .group_by(&:itself)
    .map { |k,v| [v.size, k] }
    .sort_by { |repeat,char| [-repeat,char] }
    .take(5).map(&:last).join
  next unless chksum == computed_checksum
  code.chars.map do |letter|
      case letter
      when ?- then ?-
      else Alphabet[(Alphabet.find_index(letter)+sector.to_i) % Alphabet.size] end
  end.join
  .match(/northpole/).tap { |found_mayb| p sector if found_mayb }
end

#!/usr/bin/env ruby
require 'digest/md5'
puzzle_input = "cxdnnyjw"
p (1.step.lazy
   .map do |i|
     *preamble,place,char = Digest::MD5.hexdigest(puzzle_input + i.to_s)[0...7].chars
     [place.to_i, char] if preamble.join == ?0*5 && (?0..?7) === place
   end
   .reject(&:nil?)
   .with_object([]).map do |(place,char),secret|
     secret[place] ||= char
     secret
   end
   .detect { |secret| secret.compact.size == 8 }.join)

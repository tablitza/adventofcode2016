#!/usr/bin/env ruby
require 'digest/md5'
puzzle_input = "cxdnnyjw"
p (1.step.lazy
   .map do |i|
     *preamble,char = Digest::MD5.hexdigest(puzzle_input + i.to_s)[0...6].chars
     char if preamble.join == ?0*5
   end
   .reject(&:nil?)
   .take(8).to_a.join)

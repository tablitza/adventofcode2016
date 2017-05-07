#!/usr/bin/env ruby
require "parslet"

class PuzzleP < Parslet::Parser
  root :layers
  rule(:layers) { (hypernet | supernet).repeat.as(:layers) }
  rule(:hypernet) { str("[") >> text.as(:hnet) >> str("]") }
  rule(:supernet) { text.as :snet }
  rule(:text) { match["a-z"].repeat(1).as(:text) }
end

class PuzzleT < Parslet::Transform
  rule(layers: subtree(:layers)) do
    layers.reduce({}) do |memo,layer|
      memo.merge!(layer) { |_,payloads,nxt| payloads.concat nxt }
    end
  end

  rule(text: simple(:text)) do
    [ String(text) ].tap { |(payload,*)|
      payload.define_singleton_method :abba do
        match /(.)(?!\1)(.)\2\1/
      end }
  end
end

pa,tr = PuzzleP.new, PuzzleT.new
p (File.open("inputs/7.inp").each_line.count do |line|
  parsed = pa.parse line.chomp
  layers = tr.apply parsed
  supernet,hypernet = [:snet,:hnet].map &layers
  
  supernet.any?(&:abba) && hypernet.none?(&:abba)
end)

#!/usr/bin/env ruby
%w[parslet pattern-match].each { |v| require v }

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
      payload.define_singleton_method :abas do
        WithMatcher.abas(chars).to_a
      end }
  end
end

module WithMatcher; using PatternMatch
  def self.abas window
    return to_enum(:abas,window) unless block_given?
    loop do
      match(window) do
        with(_[_,___?,a,b,a,*rest], guard { a != b }) do
          yield [a,b,a].join.extend(self)
          window = [b,a].concat rest
        end
        with(_) { raise StopIteration }
      end
    end
    def to_bab
      a,b,* = chars
      [b,a,b].join
    end
  end end

pa,tr = PuzzleP.new, PuzzleT.new
p (File.open("inputs/7.inp").each_line.count do |line|
  parsed = pa.parse line.chomp
  layers = tr.apply parsed
  supernet,hypernet = [:snet,:hnet].map &layers
  
  babs = supernet.flat_map(&:abas).map &:to_bab
  hypernet.product(babs).any? { |hnet,bab| hnet[bab] }
end)

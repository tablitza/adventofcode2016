require "parslet"

Simple = Struct.new :len do
  def apply; len; end
  def self.length_for(parse) new parse.to_s.length end
end

Nested = Struct.new :rep, :children do
  def apply
    rep * children.map(&:apply).sum
  end
end

class Parser < Parslet::Parser
  rule(:start) { nested.repeat(1) }
  rule(:raw) { (any.repeat 1).as :raw }
  rule(:nested) do
    str(?() >> number.capture(:len) >> str(?x) >> number.as(:rep) >> str(?)) >>
      dynamic { |_,context|
        len = Integer context.captures[:len]
        any.repeat(len,len).as :inner
      } end
  rule(:number) { match["0-9"].repeat(1) }
end

class Transform < Parslet::Transform
  rule(raw: simple(:payload)) do
    [ Simple.length_for(payload) ]
  end
  rule(inner: simple(:payload), rep: simple(:rep)) do
    Nested[ rep.to_i, ::Transform.new.apply(::Parser.new.raw.parse payload.to_s) ]
  end
end

intermediate = Parser.new.start.parse File.read("inputs/9.inp").chomp
instructions = Transform.new.apply intermediate
puts (instructions.reduce 0 do |memo,nxt|
       memo + nxt.apply
     end)

require "parslet"

class Parser < Parslet::Parser
  rule :start do
    (instruction >> ws).repeat 1
  end
  rule :instruction do
    award | pass_lo_hi
  end
  rule(:award) { (str "value ") >> (num.as :value) >> (str " goes to bot ") >> (num.as :bot) }
  rule :pass_lo_hi do
    (str "bot ") >> (num.as :bot) >> (str " gives low to ") >> (where.as :low) >>
    (str " and high to ") >> (where.as :high)
  end
  rule :where do
    ((str "bot ") >> (num.as :bot)) | ((str "output ") >> (num.as :output))
  end
  rule(:num) { (match["0-9"].repeat 1).as :num }
  rule(:ws) { match["\s\n"].repeat.maybe }
end

class Transform < Parslet::Transform
  rule(num: simple(:payload)) { Integer payload }
  # lambda hands value to target bot
  rule(bot: simple(:target)) { -> val { $bots[target] << val } }
  # lambda writes [bin, value] to output log array
  rule(output: simple(:bin)) { -> val { $outputs << [bin, val] } }
  rule bot: simple(:target), low: simple(:low), high: simple(:high) do
    -> &blk {
      if $bots[target].size == 2
        lo, hi = $bots[target].sort
        blk.call target,[lo,hi]
        low.call lo
        high.call hi
        $queue.shift
      else $queue.push $queue.shift end
    }
  end
  rule value: simple(:value), bot: simple(:target) do
    -> {
      $bots[target] << value
      $queue.shift
    }
  end
end

intermediate = Parser.new.start.parse(File.read "inputs/10.inp")
$queue = Transform.new.apply intermediate
$bots = Hash.new { |h,k| h[k] = [] }
$outputs = []
loop do
  raise StopIteration if $queue.empty?
  $queue.first.call do |bot,comparing|
    target = 17,61
    p "bot #{bot} compares #{target}" and raise StopIteration if comparing == target
  end
end

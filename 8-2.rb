require "parslet"
require "set"

COLS, ROWS = 50, 6
class PuzzleP < Parslet::Parser
  root :program
  rule(:program) { (command >> newline).repeat }
  rule(:command) { make_rect.as(:rect) | rotate.as(:rot) }
  rule(:make_rect) { str("rect ") >> (n.as(:f) >> str("x") >> n.as(:s)).as(:pair) }
  rule(:rotate) { str("rotate ") >> (row.as(:row_shift) | col.as(:col_shift)) }
  rule(:row) { str("row y=") >> shift }
  rule(:col) { str("column x=") >> shift }
  rule(:shift) { (n.as(:f) >> str(" by ") >> n.as(:s)).as(:pair) }
  rule(:n) { match["0-9"].repeat.as(:number) }
  rule(:newline) { match("\n").maybe }
end

class PuzzleT < Parslet::Transform
  rule(number: simple(:payload)) { Integer payload }
  rule(pair: subtree(:payload)) { payload.values_at :f, :s }

  rule(rect: sequence(:pair)) do
    ncols, nrows = pair
    Object.new.tap do |o|
      o.define_singleton_method(:apply) do |screen|
        rect = [*0...nrows].product [*0...ncols]
        screen.merge rect
      end end
  end

  rule(row_shift: sequence(:pair)) do
    with_row, by = pair
    selection = [with_row].product [*0..COLS]
    -> screen {
      updated_selection =
        (screen & selection).map { |row,col| [row, (col + by) % COLS] }
      screen.subtract(selection).merge(updated_selection)
    } end

  rule(col_shift: sequence(:pair)) do
    with_col, by = pair
    selection = [*0..ROWS].product [with_col]
    -> screen {
      updated_selection =
        (screen & selection).map { |row,col| [(row + by) % ROWS, col] }
      screen.subtract(selection).merge(updated_selection)
    } end

  rule(rot: simple(:shift)) do
    Object.new.tap do |o|
      o.define_singleton_method :apply, &shift
    end end
end

parsed = PuzzleP.new.parse File.read("inputs/8.inp")
instructions = PuzzleT.new.apply parsed
instructions.reduce(Set[]) { |screen,instr| instr.apply screen }
  .tap { |pixels|
    [*0...ROWS].product([*0...COLS])
      .map { |lit| pixels.include?(lit) ? ?#: ?. }
      .each_slice(COLS) { |line| puts line.join }
  }

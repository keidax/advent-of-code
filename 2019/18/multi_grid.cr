require "./grid"

class MultiGrid < Grid
  @original_start : Neighbor

  def initialize(input)
    super(input)

    @original_start = find('@')
    replace_start = [
      ['@', '#', '@'],
      ['#', '#', '#'],
      ['@', '#', '@'],
    ]

    replace_start.each_with_index do |row, y_off|
      row.each_with_index do |char, x_off|
        @data[
          @original_start[:y] - 1 + y_off,
        ][
          @original_start[:x] - 1 + x_off,
        ] = char
      end
    end
  end

  def starts : Array(Neighbor)
    return [
      {
        x: @original_start[:x] + 1, y: @original_start[:y] + 1,
      }, {
        x: @original_start[:x] + 1, y: @original_start[:y] - 1,
      }, {
        x: @original_start[:x] - 1, y: @original_start[:y] - 1,
      }, {
        x: @original_start[:x] - 1, y: @original_start[:y] + 1,
      },
    ]
  end
end

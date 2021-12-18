input_str =
  IO.read(:line)
  |> String.trim()

length_in_bits = String.length(input_str) * 4

input =
  input_str
  |> String.to_integer(16)
  |> then(&<<&1::size(length_in_bits)>>)

defmodule Day16 do
  use Bitwise

  def parse_packet(<<version::3, 4::3, literal::bits>>) do
    {literal_value, remaining} = parse_literal(literal)

    {{:literal, version, literal_value}, remaining}
  end

  def parse_packet(
        <<version::3, type::3, 0::1, len::15, contents::bits-size(len), remaining::bits>>
      ) do
    subpackets = parse_packets(contents)

    {{:operator, version, type, subpackets}, remaining}
  end

  def parse_packet(<<version::3, type::3, 1::1, count::11, contents::bits>>) do
    {subpackets, remaining} = parse_packets(contents, count)

    {{:operator, version, type, subpackets}, remaining}
  end

  # Parse literal packet value
  def parse_literal(bits, acc \\ 0)

  def parse_literal(<<1::1, num::4, rest::bits>>, acc) do
    acc = (acc <<< 4) + num

    parse_literal(rest, acc)
  end

  def parse_literal(<<0::1, num::4, remaining::bits>>, acc) do
    {(acc <<< 4) + num, remaining}
  end

  # Parse operator subpackets when the packets fit exactly in `bits`.
  def parse_packets(list \\ [], bits)

  def parse_packets(packet_list, <<>>) do
    Enum.reverse(packet_list)
  end

  def parse_packets(packet_list, bits) when is_bitstring(bits) do
    {packet, remaining} = parse_packet(bits)

    parse_packets([packet | packet_list], remaining)
  end

  # Parse operator subpackets when the number of subpackets is known.
  def parse_packets(remaining, count) when is_integer(count) do
    parse_packets([], remaining, count)
  end

  def parse_packets(packet_list, remaining, 0) do
    {Enum.reverse(packet_list), remaining}
  end

  def parse_packets(packet_list, bits, count) do
    {packet, remaining} = parse_packet(bits)

    parse_packets([packet | packet_list], remaining, count - 1)
  end

  def version_sum({:literal, version, _value}) do
    version
  end

  def version_sum({:operator, version, _type, subpackets}) do
    subpacket_versions =
      subpackets
      |> Enum.map(&version_sum/1)
      |> Enum.sum()

    version + subpacket_versions
  end

  def packet_value({:literal, _version, value}), do: value

  def packet_value({:operator, _version, type, subpackets}) do
    packet_values = subpackets |> Enum.map(&packet_value/1)

    value_fn =
      case type do
        0 ->
          &Enum.sum/1

        1 ->
          &Enum.product/1

        2 ->
          &Enum.min/1

        3 ->
          &Enum.max/1

        5 ->
          fn
            [a, b] when a > b -> 1
            [_, _] -> 0
          end

        6 ->
          fn
            [a, b] when a < b -> 1
            [_, _] -> 0
          end

        7 ->
          fn
            [a, a] -> 1
            [_, _] -> 0
          end
      end

    value_fn.(packet_values)
  end
end

# Part 1
{packet, _padding} =
  input
  |> Day16.parse_packet()

packet
|> Day16.version_sum()
|> IO.inspect()

# Part 2
packet
|> Day16.packet_value()
|> IO.inspect()

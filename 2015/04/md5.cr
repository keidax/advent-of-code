class MD5Reader
  TABLE = StaticArray(UInt32, 64).new do |i|
    (4294967296 * Math.sin(i + 1).abs).to_u32!
  end

  SHIFT = [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
  ]

  @bit_size : UInt64 = 0

  def initialize(@io : IO)
  end

  def each_chunk(&block : Bytes ->)
    slice = Bytes.new(64, 0)

    read_bytes = 0
    loop do
      read_bytes = @io.read(slice)
      @bit_size += read_bytes*8
      break if read_bytes < 64
      yield slice
    end

    slice[read_bytes] = 0x80
    read_bytes += 1

    if read_bytes > 56
      (read_bytes...64).each do |i|
        slice[i] = 0
      end
      yield slice
      read_bytes = 0
    end

    (read_bytes..55).each do |i|
      slice[i] = 0
    end

    IO::ByteFormat::LittleEndian.encode(@bit_size, slice + 56)
    yield slice
  end

  def md5 : UInt128
    a_word = 0x67452301_u32
    b_word = 0xefcdab89_u32
    c_word = 0x98badcfe_u32
    d_word = 0x10325476_u32

    each_chunk do |bytes|
      temp_a = a_word
      temp_b = b_word
      temp_c = c_word
      temp_d = d_word

      (0..63).each do |i|
        temp_f, g = 0_u32, 0_u32

        case i
        when 0..15
          temp_f = (temp_b & temp_c) | (~temp_b & temp_d)
          g = i
        when 16..31
          temp_f = (temp_d & temp_b) | (~temp_d & temp_c)
          g = (5 * i + 1) % 16
        when 32..47
          temp_f = (temp_b ^ temp_c ^ temp_d)
          g = (3 * i + 5) % 16
        when 48..63
          temp_f = temp_c ^ (temp_b | ~temp_d)
          g = (7 * i) % 16
        end

        msg_chunk : UInt32 = bytes[4*g].to_u32 + (bytes[4*g + 1].to_u32 << 8) + (bytes[4*g + 2].to_u32 << 16) + (bytes[4*g + 3].to_u32 << 24)
        temp_f = temp_f &+ temp_a &+ TABLE[i] &+ msg_chunk
        temp_a = temp_d
        temp_d = temp_c
        temp_c = temp_b
        temp_b = temp_b &+ ((temp_f << SHIFT[i]) | (temp_f >> (32 - SHIFT[i])))
      end

      a_word &+= temp_a
      b_word &+= temp_b
      c_word &+= temp_c
      d_word &+= temp_d
    end

    a_word.to_u128 + (b_word.to_u128 << 32) + (c_word.to_u128 << 64) + (d_word.to_u128 << 96)
  end

  def to_s(io)
    hash = IO::Memory.new
    hash.write_bytes(md5, IO::ByteFormat::LittleEndian)
    hash.rewind
    hash.each_byte do |byte|
      io.printf("%02x", byte)
    end
  end
end

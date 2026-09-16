module Stack
  module Protocol
    # CRC-32C (Castagnoli), implemented directly. No external deps.
    module Checksum
      POLY = 0x82F63B78_u32

      @@table : StaticArray(UInt32, 256)?

      def self.table : StaticArray(UInt32, 256)
        if t = @@table
          t
        else
          tbl = StaticArray(UInt32, 256).new(0_u32)
          256.times do |i|
            crc = i.to_u32
            8.times do
              crc = (crc >> 1) ^ (POLY & (0_u32 - (crc & 1)))
            end
            tbl[i] = crc
          end
          @@table = tbl
          tbl
        end
      end

      def self.compute(bytes : Bytes) : UInt32
        crc = 0xFFFFFFFF_u32
        tbl = table
        bytes.each do |b|
          crc = (crc >> 8) ^ tbl[(crc ^ b) & 0xFF_u32]
        end
        crc ^ 0xFFFFFFFF_u32
      end
    end
  end
end

module Stack
  module Protocol
    MAGIC = 0x44535948_u32 # "HSYD" little-endian
    VERSION = 1_u16
    MAX_PAYLOAD = 64 * 1024 * 1024 # 64 MiB

    enum Opcode : UInt8
      Compute  = 0x01
      Batch    = 0x02
      Memory   = 0x03
      Device   = 0x04
      Status   = 0x05
      Shutdown = 0x06
    end

    enum Status : UInt8
      Ok          = 0x00
      BadFrame    = 0x01
      BadOpcode   = 0x02
      BadChecksum = 0x03
      TooLarge    = 0x04
      GpuError    = 0x05
      Timeout     = 0x06
      QueueFull   = 0x07
      Internal    = 0x08
    end

    enum Flags : UInt8
      None       = 0x00
      ZeroCopy   = 0x01
      Pinned     = 0x02
      BatchAsync = 0x04
    end
  end
end

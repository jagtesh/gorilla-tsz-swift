/// A variable-length bit stream for reading and writing.
///
/// Port of `bstream` from `dgryski/go-tsz`.
/// Bits are packed MSB-first within each byte.
public struct BitStream: Sendable {

    /// The raw byte buffer.
    public private(set) var stream: [UInt8]

    /// For writing: number of bits remaining in current byte (0 = need new byte).
    /// For reading: number of bits remaining in current byte at readOffset.
    public private(set) var count: UInt8

    /// Read cursor (byte offset into stream). Only used by read operations.
    private var readOffset: Int = 0

    // MARK: - Init

    /// Create an empty writer with pre-allocated capacity.
    public init(capacity: Int = 64) {
        self.stream = []
        self.stream.reserveCapacity(capacity)
        self.count = 0
    }

    /// Create a reader from existing bytes.
    public init(bytes: [UInt8]) {
        self.stream = bytes
        self.count = 8
        self.readOffset = 0
    }

    /// Clone the bit stream (preserves read position).
    public func clone() -> BitStream {
        var bs = BitStream(bytes: stream)
        bs.count = count
        bs.readOffset = readOffset
        return bs
    }

    /// Raw bytes of the stream.
    public var bytes: [UInt8] { stream }

    // MARK: - Writing

    /// Write a single bit.
    public mutating func writeBit(_ bit: Bool) {
        if count == 0 {
            stream.append(0)
            count = 8
        }

        if bit {
            let i = stream.count - 1
            stream[i] |= 1 << (count - 1)
        }

        count -= 1
    }

    /// Write a full byte.
    public mutating func writeByte(_ byt: UInt8) {
        if count == 0 {
            stream.append(0)
            count = 8
        }

        let i = stream.count - 1
        stream[i] |= byt >> (8 - count)

        stream.append(0)
        stream[stream.count - 1] = byt << count
    }

    /// Write the lowest `nbits` of `u`.
    public mutating func writeBits(_ u: UInt64, _ nbits: Int) {
        var u = u << (64 - UInt64(nbits))
        var remaining = nbits

        while remaining >= 8 {
            let byt = UInt8(u >> 56)
            writeByte(byt)
            u <<= 8
            remaining -= 8
        }

        while remaining > 0 {
            writeBit((u >> 63) == 1)
            u <<= 1
            remaining -= 1
        }
    }

    // MARK: - Reading (index-based, no array mutation)

    /// Read a single bit. Returns `nil` at end of stream.
    public mutating func readBit() -> Bool? {
        if readOffset >= stream.count { return nil }

        if count == 0 {
            readOffset += 1
            if readOffset >= stream.count { return nil }
            count = 8
        }

        count -= 1
        let d = stream[readOffset] & 0x80
        stream[readOffset] <<= 1
        return d != 0
    }

    /// Read a full byte. Returns `nil` at end of stream.
    public mutating func readByte() -> UInt8? {
        if readOffset >= stream.count { return nil }

        if count == 0 {
            readOffset += 1
            if readOffset >= stream.count { return nil }
            count = 8
        }

        if count == 8 {
            count = 0
            return stream[readOffset]
        }

        var byt = stream[readOffset]
        readOffset += 1

        if readOffset >= stream.count { return nil }

        byt |= stream[readOffset] >> count
        stream[readOffset] <<= (8 - count)

        return byt
    }

    /// Read `nbits` bits as a UInt64. Returns `nil` at end of stream.
    public mutating func readBits(_ nbits: Int) -> UInt64? {
        var u: UInt64 = 0
        var remaining = nbits

        while remaining >= 8 {
            guard let byt = readByte() else { return nil }
            u = (u << 8) | UInt64(byt)
            remaining -= 8
        }

        if remaining == 0 { return u }

        if remaining > Int(count) {
            if readOffset >= stream.count { return nil }
            u = (u << UInt64(count)) | UInt64(stream[readOffset] >> (8 - count))
            remaining -= Int(count)
            readOffset += 1

            if readOffset >= stream.count { return nil }
            count = 8
        }

        if readOffset >= stream.count { return nil }
        u = (u << UInt64(remaining)) | UInt64(stream[readOffset] >> (8 - UInt8(remaining)))
        stream[readOffset] <<= UInt8(remaining)
        count -= UInt8(remaining)
        return u
    }
}

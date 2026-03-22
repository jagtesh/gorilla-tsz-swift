import Foundation

/// A compressed time series using Facebook's Gorilla TSZ algorithm.
///
/// Port of `Series` from `dgryski/go-tsz`.
///
/// Usage:
/// ```swift
/// var series = Series(t0: startTimestamp)
/// series.push(t: 1000, v: 42.5)
/// series.push(t: 1060, v: 43.1)
/// series.finish()
/// let compressed = series.bytes
/// ```
///
/// Reference: http://www.vldb.org/pvldb/vol8/p1816-teller.pdf
public struct Series: Sendable {

    /// Block header timestamp.
    public let t0: UInt32

    private var t: UInt32 = 0
    private var val: Float64 = 0

    private var bw: BitStream
    private var leading: UInt8 = .max
    private var trailing: UInt8 = 0
    private var finished: Bool = false

    private var tDelta: UInt32 = 0

    // MARK: - Init

    /// Create a new series with block header timestamp `t0`.
    public init(t0: UInt32) {
        self.t0 = t0
        self.bw = BitStream(capacity: 128)

        // Write block header
        bw.writeBits(UInt64(t0), 32)
    }

    // MARK: - Bytes

    /// Compressed bytes of the series.
    public var bytes: [UInt8] { bw.bytes }

    // MARK: - Push

    /// Push a data point (timestamp, value) into the series.
    public mutating func push(t: UInt32, v: Float64) {
        precondition(!finished, "Cannot push to a finished series")

        if self.t == 0 {
            // First point
            self.t = t
            self.val = v
            self.tDelta = t &- t0
            bw.writeBits(UInt64(tDelta), 14)
            bw.writeBits(v.bitPattern, 64)
            return
        }

        let tDelta = t &- self.t
        let dod = Int32(bitPattern: tDelta &- self.tDelta)

        switch dod {
        case 0:
            bw.writeBit(false)  // '0'
        case -63...64:
            bw.writeBits(0x02, 2)  // '10'
            bw.writeBits(UInt64(bitPattern: Int64(dod)), 7)
        case -255...256:
            bw.writeBits(0x06, 3)  // '110'
            bw.writeBits(UInt64(bitPattern: Int64(dod)), 9)
        case -2047...2048:
            bw.writeBits(0x0e, 4)  // '1110'
            bw.writeBits(UInt64(bitPattern: Int64(dod)), 12)
        default:
            bw.writeBits(0x0f, 4)  // '1111'
            bw.writeBits(UInt64(bitPattern: Int64(dod)), 32)
        }

        // Value encoding: XOR with previous
        let vDelta = v.bitPattern ^ val.bitPattern

        if vDelta == 0 {
            bw.writeBit(false)  // '0' — same value
        } else {
            bw.writeBit(true)  // '1' — value changed

            let leadingZeros = UInt8(min(vDelta.leadingZeroBitCount, 31))
            let trailingZeros = UInt8(vDelta.trailingZeroBitCount)

            if leading != .max && leadingZeros >= leading && trailingZeros >= trailing {
                // Reuse previous leading/trailing window
                bw.writeBit(false)  // '0'
                let sigbits = 64 - Int(leading) - Int(trailing)
                bw.writeBits(vDelta >> trailing, sigbits)
            } else {
                // New leading/trailing window
                leading = leadingZeros
                trailing = trailingZeros

                bw.writeBit(true)  // '1'
                bw.writeBits(UInt64(leadingZeros), 5)

                let sigbits = 64 - leadingZeros - trailingZeros
                // 0 sigbits encodes as 0 but means 64 (see paper)
                bw.writeBits(UInt64(sigbits), 6)
                bw.writeBits(vDelta >> trailingZeros, Int(sigbits))
            }
        }

        self.tDelta = tDelta
        self.t = t
        self.val = v
    }

    /// Finish the series by writing an end-of-stream marker.
    public mutating func finish() {
        guard !finished else { return }
        Self.writeFinishMarker(&bw)
        finished = true
    }

    /// Write the end-of-stream marker to a bitstream.
    static func writeFinishMarker(_ bw: inout BitStream) {
        bw.writeBits(0x0f, 4)
        bw.writeBits(0xFFFFFFFF, 32)
        bw.writeBit(false)
    }
}

// MARK: - Iterator

/// Iterator for decompressing a Gorilla TSZ series.
///
/// Port of `Iter` from `dgryski/go-tsz`.
///
/// Usage:
/// ```swift
/// var iter = Iterator(bytes: compressedBytes)
/// while iter.next() {
///     let (timestamp, value) = iter.values()
///     print("\(timestamp): \(value)")
/// }
/// ```
public struct Iterator {

    /// Block header timestamp.
    public let t0: UInt32

    private var t: UInt32 = 0
    private var val: Float64 = 0

    private var br: BitStream
    private var leading: UInt8 = 0
    private var trailing: UInt8 = 0
    private var finished: Bool = false
    private var tDelta: UInt32 = 0
    private var _error: Bool = false

    // MARK: - Init

    /// Create an iterator from compressed bytes.
    public init?(bytes: [UInt8]) {
        var bs = BitStream(bytes: bytes)
        guard let t0raw = bs.readBits(32) else { return nil }
        self.t0 = UInt32(t0raw)
        self.br = bs
    }

    // MARK: - Iteration

    /// Advance to the next data point.
    /// Returns `true` if a data point was decoded, `false` at end of stream or on error.
    public mutating func next() -> Bool {
        if _error || finished { return false }

        if t == 0 {
            // Read first data point
            guard let tDeltaRaw = br.readBits(14) else { _error = true; return false }
            tDelta = UInt32(tDeltaRaw)
            t = t0 &+ tDelta

            guard let vRaw = br.readBits(64) else { _error = true; return false }
            val = Float64(bitPattern: vRaw)
            return true
        }

        // Read delta-of-delta prefix
        var d: UInt8 = 0
        for _ in 0..<4 {
            d <<= 1
            guard let bit = br.readBit() else { _error = true; return false }
            if !bit { break }
            d |= 1
        }

        var dod: Int32 = 0
        var sz: Int = 0

        switch d {
        case 0x00:
            // dod == 0
            break
        case 0x02:
            sz = 7
        case 0x06:
            sz = 9
        case 0x0e:
            sz = 12
        case 0x0f:
            guard let bits = br.readBits(32) else { _error = true; return false }
            // End-of-stream marker
            if bits == 0xFFFFFFFF {
                finished = true
                return false
            }
            dod = Int32(bitPattern: UInt32(bits))
        default:
            _error = true
            return false
        }

        if sz != 0 {
            guard let bits = br.readBits(sz) else { _error = true; return false }
            if bits > (1 << (sz - 1)) {
                // Sign-extend: negative value
                dod = Int32(bitPattern: UInt32(bits) &- UInt32(1 << sz))
            } else {
                dod = Int32(bits)
            }
        }

        tDelta = tDelta &+ UInt32(bitPattern: dod)
        t = t &+ tDelta

        // Read compressed value
        guard let valueBit = br.readBit() else { _error = true; return false }

        if !valueBit {
            // Same value as previous
        } else {
            guard let controlBit = br.readBit() else { _error = true; return false }
            if !controlBit {
                // Reuse previous leading/trailing
            } else {
                guard let leadBits = br.readBits(5) else { _error = true; return false }
                leading = UInt8(leadBits)

                guard let sigBits = br.readBits(6) else { _error = true; return false }
                var mbits = UInt8(sigBits)
                // 0 means 64 (overflow encoding; see paper)
                if mbits == 0 { mbits = 64 }
                trailing = 64 - leading - mbits
            }

            let mbits = Int(64 - leading - trailing)
            guard let bits = br.readBits(mbits) else { _error = true; return false }
            let vbits = val.bitPattern ^ (bits << trailing)
            val = Float64(bitPattern: vbits)
        }

        return true
    }

    /// Current timestamp and value.
    public func values() -> (timestamp: UInt32, value: Float64) {
        return (t, val)
    }

    /// Whether an error occurred during iteration.
    public var hasError: Bool { _error }
}

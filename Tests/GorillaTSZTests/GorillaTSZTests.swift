import XCTest
@testable import GorillaTSZ

/// Port of go-tsz test data: 120 data points, one per 60s, from the Gorilla paper.
struct TestPoint {
    let v: Float64
    let t: UInt32
}

let twoHoursData: [TestPoint] = [
    TestPoint(v: 761, t: 1440583200), TestPoint(v: 727, t: 1440583260), TestPoint(v: 765, t: 1440583320), TestPoint(v: 706, t: 1440583380), TestPoint(v: 700, t: 1440583440),
    TestPoint(v: 679, t: 1440583500), TestPoint(v: 757, t: 1440583560), TestPoint(v: 708, t: 1440583620), TestPoint(v: 739, t: 1440583680), TestPoint(v: 707, t: 1440583740),
    TestPoint(v: 699, t: 1440583800), TestPoint(v: 740, t: 1440583860), TestPoint(v: 729, t: 1440583920), TestPoint(v: 766, t: 1440583980), TestPoint(v: 730, t: 1440584040),
    TestPoint(v: 715, t: 1440584100), TestPoint(v: 705, t: 1440584160), TestPoint(v: 693, t: 1440584220), TestPoint(v: 765, t: 1440584280), TestPoint(v: 724, t: 1440584340),
    TestPoint(v: 799, t: 1440584400), TestPoint(v: 761, t: 1440584460), TestPoint(v: 737, t: 1440584520), TestPoint(v: 766, t: 1440584580), TestPoint(v: 756, t: 1440584640),
    TestPoint(v: 719, t: 1440584700), TestPoint(v: 722, t: 1440584760), TestPoint(v: 801, t: 1440584820), TestPoint(v: 747, t: 1440584880), TestPoint(v: 731, t: 1440584940),
    TestPoint(v: 742, t: 1440585000), TestPoint(v: 744, t: 1440585060), TestPoint(v: 791, t: 1440585120), TestPoint(v: 750, t: 1440585180), TestPoint(v: 759, t: 1440585240),
    TestPoint(v: 809, t: 1440585300), TestPoint(v: 751, t: 1440585360), TestPoint(v: 705, t: 1440585420), TestPoint(v: 770, t: 1440585480), TestPoint(v: 792, t: 1440585540),
    TestPoint(v: 727, t: 1440585600), TestPoint(v: 762, t: 1440585660), TestPoint(v: 772, t: 1440585720), TestPoint(v: 721, t: 1440585780), TestPoint(v: 748, t: 1440585840),
    TestPoint(v: 753, t: 1440585900), TestPoint(v: 744, t: 1440585960), TestPoint(v: 716, t: 1440586020), TestPoint(v: 776, t: 1440586080), TestPoint(v: 659, t: 1440586140),
    TestPoint(v: 789, t: 1440586200), TestPoint(v: 766, t: 1440586260), TestPoint(v: 758, t: 1440586320), TestPoint(v: 690, t: 1440586380), TestPoint(v: 795, t: 1440586440),
    TestPoint(v: 770, t: 1440586500), TestPoint(v: 758, t: 1440586560), TestPoint(v: 723, t: 1440586620), TestPoint(v: 767, t: 1440586680), TestPoint(v: 765, t: 1440586740),
    TestPoint(v: 693, t: 1440586800), TestPoint(v: 706, t: 1440586860), TestPoint(v: 681, t: 1440586920), TestPoint(v: 727, t: 1440586980), TestPoint(v: 724, t: 1440587040),
    TestPoint(v: 780, t: 1440587100), TestPoint(v: 678, t: 1440587160), TestPoint(v: 696, t: 1440587220), TestPoint(v: 758, t: 1440587280), TestPoint(v: 740, t: 1440587340),
    TestPoint(v: 735, t: 1440587400), TestPoint(v: 700, t: 1440587460), TestPoint(v: 742, t: 1440587520), TestPoint(v: 747, t: 1440587580), TestPoint(v: 752, t: 1440587640),
    TestPoint(v: 734, t: 1440587700), TestPoint(v: 743, t: 1440587760), TestPoint(v: 732, t: 1440587820), TestPoint(v: 746, t: 1440587880), TestPoint(v: 770, t: 1440587940),
    TestPoint(v: 780, t: 1440588000), TestPoint(v: 710, t: 1440588060), TestPoint(v: 731, t: 1440588120), TestPoint(v: 712, t: 1440588180), TestPoint(v: 712, t: 1440588240),
    TestPoint(v: 741, t: 1440588300), TestPoint(v: 770, t: 1440588360), TestPoint(v: 770, t: 1440588420), TestPoint(v: 754, t: 1440588480), TestPoint(v: 718, t: 1440588540),
    TestPoint(v: 670, t: 1440588600), TestPoint(v: 775, t: 1440588660), TestPoint(v: 749, t: 1440588720), TestPoint(v: 795, t: 1440588780), TestPoint(v: 756, t: 1440588840),
    TestPoint(v: 741, t: 1440588900), TestPoint(v: 787, t: 1440588960), TestPoint(v: 721, t: 1440589020), TestPoint(v: 745, t: 1440589080), TestPoint(v: 782, t: 1440589140),
    TestPoint(v: 765, t: 1440589200), TestPoint(v: 780, t: 1440589260), TestPoint(v: 811, t: 1440589320), TestPoint(v: 790, t: 1440589380), TestPoint(v: 836, t: 1440589440),
    TestPoint(v: 743, t: 1440589500), TestPoint(v: 858, t: 1440589560), TestPoint(v: 739, t: 1440589620), TestPoint(v: 762, t: 1440589680), TestPoint(v: 770, t: 1440589740),
    TestPoint(v: 752, t: 1440589800), TestPoint(v: 763, t: 1440589860), TestPoint(v: 795, t: 1440589920), TestPoint(v: 792, t: 1440589980), TestPoint(v: 746, t: 1440590040),
    TestPoint(v: 786, t: 1440590100), TestPoint(v: 785, t: 1440590160), TestPoint(v: 774, t: 1440590220), TestPoint(v: 786, t: 1440590280), TestPoint(v: 718, t: 1440590340),
]

// MARK: - Tests ported from dgryski/go-tsz

final class GorillaTSZTests: XCTestCase {

    // MARK: - TestExampleEncoding (from paper)

    func testExampleEncoding() {
        // Example from the Gorilla paper with extra edge cases
        let t0: UInt32 = 1427162400  // Mar 24 2015 02:00:00 (arbitrary)
        var s = Series(t0: t0)
        var tunix = t0

        tunix += 62;  s.push(t: tunix, v: 12)
        tunix += 60;  s.push(t: tunix, v: 12)
        tunix += 60;  s.push(t: tunix, v: 24)

        // Extra tests from go-tsz
        tunix += 60;  s.push(t: tunix, v: 13)  // floating point masking/shifting
        tunix += 60;  s.push(t: tunix, v: 24)

        // Delta-of-delta sizes
        tunix += 300; s.push(t: tunix, v: 24)   // dod = 240
        tunix += 900; s.push(t: tunix, v: 24)   // dod = 600
        tunix += 900 + 2050; s.push(t: tunix, v: 24)  // dod = 2050

        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        let want: [(t: UInt32, v: Float64)] = [
            (t0 + 62,  12),
            (t0 + 122, 12),
            (t0 + 182, 24),
            (t0 + 242, 13),
            (t0 + 302, 24),
            (t0 + 602, 24),
            (t0 + 1502, 24),
            (t0 + 4452, 24),
        ]

        for w in want {
            XCTAssertTrue(iter.next(), "Expected next() to return true")
            let (tt, vv) = iter.values()
            XCTAssertEqual(w.t, tt, "Timestamp mismatch")
            XCTAssertEqual(w.v, vv, "Value mismatch")
        }

        XCTAssertFalse(iter.next(), "Expected next() to return false at end")
        XCTAssertFalse(iter.hasError, "Expected no error")
    }

    // MARK: - TestRoundtrip (120 points)

    func testRoundtrip() {
        var s = Series(t0: twoHoursData[0].t)
        for p in twoHoursData {
            s.push(t: p.t, v: p.v)
        }
        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        for (i, w) in twoHoursData.enumerated() {
            XCTAssertTrue(iter.next(), "Next()=false at index \(i), want true")
            let (tt, vv) = iter.values()
            XCTAssertEqual(w.t, tt, "Timestamp mismatch at index \(i)")
            XCTAssertEqual(w.v, vv, "Value mismatch at index \(i)")
        }

        XCTAssertFalse(iter.next(), "Next()=true, want false")
        XCTAssertFalse(iter.hasError, "Expected no error")
    }

    // MARK: - TestEncodeSimilarFloats

    func testEncodeSimilarFloats() {
        let tunix: UInt32 = 0
        var s = Series(t0: tunix)
        let want: [(t: UInt32, v: Float64)] = [
            (tunix,     6.00065e+06),
            (tunix + 1, 6.000656e+06),
            (tunix + 2, 6.000657e+06),
            (tunix + 3, 6.000659e+06),
            (tunix + 4, 6.000661e+06),
        ]

        for w in want {
            s.push(t: w.t, v: w.v)
        }
        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        for w in want {
            XCTAssertTrue(iter.next(), "Next()=false, want true")
            let (tt, vv) = iter.values()
            XCTAssertEqual(w.t, tt, "Timestamp mismatch")
            XCTAssertEqual(w.v, vv, "Value mismatch")
        }

        XCTAssertFalse(iter.next(), "Next()=true, want false")
        XCTAssertFalse(iter.hasError, "Expected no error")
    }

    // MARK: - TestEmptyIterator

    func testEmptyIterator() {
        let iter = Iterator(bytes: [])
        XCTAssertNil(iter, "Expected nil iterator for empty bytes")
    }

    // MARK: - TestCompressionRatio

    func testCompressionRatio() {
        var s = Series(t0: twoHoursData[0].t)
        for p in twoHoursData {
            s.push(t: p.t, v: p.v)
        }
        s.finish()

        let rawSize = twoHoursData.count * 12  // 4 bytes timestamp + 8 bytes value
        let compressedSize = s.bytes.count
        let ratio = Double(rawSize) / Double(compressedSize)

        print("Raw: \(rawSize) bytes, Compressed: \(compressedSize) bytes, Ratio: \(String(format: "%.1f", ratio))x")
        XCTAssertGreaterThan(ratio, 1.0, "Compression should save space")
    }

    // MARK: - TestRoundtripWithoutFinish (via Iter on unfinished series)

    func testRoundtripWithoutFinish() {
        // Test that iterating over an unfinished series still works
        // (go-tsz's Series.Iter() clones the stream and writes finish marker)
        var s = Series(t0: twoHoursData[0].t)
        for p in twoHoursData {
            s.push(t: p.t, v: p.v)
        }

        // Create iterator from current bytes — without calling finish
        // We need to manually append the finish marker to a clone
        var clone = s
        clone.finish()

        var iter = Iterator(bytes: clone.bytes)!
        for (i, w) in twoHoursData.enumerated() {
            XCTAssertTrue(iter.next(), "Next()=false at index \(i)")
            let (tt, vv) = iter.values()
            XCTAssertEqual(w.t, tt, "Timestamp mismatch at index \(i)")
            XCTAssertEqual(w.v, vv, "Value mismatch at index \(i)")
        }

        XCTAssertFalse(iter.next())
    }

    // MARK: - TestSinglePoint

    func testSinglePoint() {
        var s = Series(t0: 1000)
        s.push(t: 1060, v: 42.5)
        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        XCTAssertTrue(iter.next())
        let (t, v) = iter.values()
        XCTAssertEqual(t, 1060)
        XCTAssertEqual(v, 42.5)
        XCTAssertFalse(iter.next())
    }

    // MARK: - TestIdenticalValues

    func testIdenticalValues() {
        var s = Series(t0: 0)
        for i: UInt32 in 1...100 {
            s.push(t: i * 60, v: 777.0)
        }
        s.finish()

        let rawSize = 100 * 12
        let compressedSize = s.bytes.count
        let ratio = Double(rawSize) / Double(compressedSize)
        print("Identical values: Raw: \(rawSize) bytes, Compressed: \(compressedSize) bytes, Ratio: \(String(format: "%.1f", ratio))x")

        // Identical values with constant interval should compress extremely well
        XCTAssertGreaterThan(ratio, 5.0, "Identical values should get >5x compression")

        var iter = Iterator(bytes: s.bytes)!
        for i: UInt32 in 1...100 {
            XCTAssertTrue(iter.next())
            let (t, v) = iter.values()
            XCTAssertEqual(t, i * 60)
            XCTAssertEqual(v, 777.0)
        }
        XCTAssertFalse(iter.next())
    }

    // MARK: - TestLargeTimestampJumps

    func testLargeTimestampJumps() {
        var s = Series(t0: 0)
        let timestamps: [UInt32] = [60, 120, 180, 86400, 86460, 86520]  // jump from 180s to 86400s (1 day)
        let values: [Float64] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

        for (t, v) in zip(timestamps, values) {
            s.push(t: t, v: v)
        }
        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        for (t, v) in zip(timestamps, values) {
            XCTAssertTrue(iter.next())
            let (tt, vv) = iter.values()
            XCTAssertEqual(tt, t, "Timestamp mismatch")
            XCTAssertEqual(vv, v, "Value mismatch")
        }
        XCTAssertFalse(iter.next())
    }

    // MARK: - TestZeroValues

    func testZeroValues() {
        var s = Series(t0: 0)
        for i: UInt32 in 1...10 {
            s.push(t: i * 60, v: 0.0)
        }
        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        for i: UInt32 in 1...10 {
            XCTAssertTrue(iter.next())
            let (t, v) = iter.values()
            XCTAssertEqual(t, i * 60)
            XCTAssertEqual(v, 0.0)
        }
        XCTAssertFalse(iter.next())
    }

    // MARK: - TestNegativeValues

    func testNegativeValues() {
        var s = Series(t0: 0)
        let values: [Float64] = [-1.5, -100.0, 0.0, 100.0, -0.001, .infinity, -.infinity]
        for (i, v) in values.enumerated() {
            s.push(t: UInt32(i + 1) * 60, v: v)
        }
        s.finish()

        var iter = Iterator(bytes: s.bytes)!
        for (i, v) in values.enumerated() {
            XCTAssertTrue(iter.next())
            let (tt, vv) = iter.values()
            XCTAssertEqual(tt, UInt32(i + 1) * 60)
            XCTAssertEqual(vv, v)
        }
        XCTAssertFalse(iter.next())
    }
}

// MARK: - BitStream Tests

final class BitStreamTests: XCTestCase {

    func testWriteAndReadBit() {
        var bs = BitStream()
        bs.writeBit(true)
        bs.writeBit(false)
        bs.writeBit(true)
        bs.writeBit(true)

        var reader = BitStream(bytes: bs.bytes)
        XCTAssertEqual(reader.readBit(), true)
        XCTAssertEqual(reader.readBit(), false)
        XCTAssertEqual(reader.readBit(), true)
        XCTAssertEqual(reader.readBit(), true)
    }

    func testWriteAndReadBits() {
        var bs = BitStream()
        bs.writeBits(0xABCD, 16)
        bs.writeBits(42, 7)

        var reader = BitStream(bytes: bs.bytes)
        XCTAssertEqual(reader.readBits(16), 0xABCD)
        XCTAssertEqual(reader.readBits(7), 42)
    }

    func testWriteAndReadByte() {
        var bs = BitStream()
        bs.writeByte(0xFF)
        bs.writeByte(0x00)
        bs.writeByte(0xA5)

        var reader = BitStream(bytes: bs.bytes)
        XCTAssertEqual(reader.readByte(), 0xFF)
        XCTAssertEqual(reader.readByte(), 0x00)
        XCTAssertEqual(reader.readByte(), 0xA5)
    }

    func testMixedBitAndByteWrites() {
        var bs = BitStream()
        bs.writeBit(true)
        bs.writeBits(0x1F, 5)
        bs.writeByte(0xAB)
        bs.writeBits(0x03, 2)

        var reader = BitStream(bytes: bs.bytes)
        XCTAssertEqual(reader.readBit(), true)
        XCTAssertEqual(reader.readBits(5), 0x1F)
        XCTAssertEqual(reader.readByte(), 0xAB)
        XCTAssertEqual(reader.readBits(2), 0x03)
    }

    func testReadEmptyStream() {
        var reader = BitStream(bytes: [])
        XCTAssertNil(reader.readBit())
        XCTAssertNil(reader.readByte())
        XCTAssertNil(reader.readBits(8))
    }
}

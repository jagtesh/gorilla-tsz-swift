// Pygorilla — Python bindings for Gorilla TSZ compression
//
// Usage from Python:
//   from pygorilla import compress, decompress
//
//   compressed = compress(t0=1000, timestamps=[1060, 1120], values=[42.5, 43.1])
//   points = decompress(compressed)

import ApplePy
@preconcurrency import ApplePyFFI
import GorillaTSZ

// MARK: - Functions

/// Compress a time series into Gorilla TSZ format.
///
/// - Parameters:
///   - t0: Block header timestamp (Int64)
///   - timestamps: List of timestamps (Int64)
///   - values: List of Float64 values
/// - Returns: Compressed bytes as a list of integers (0-255)
@PyFunction
func compress(t0: Int, timestamps: [Int], values: [Double]) throws -> [Int] {
    guard timestamps.count == values.count else {
        throw PygorillaError.mismatchedLengths(
            "timestamps has \(timestamps.count) elements but values has \(values.count)")
    }

    var series = Series(t0: Int64(t0))
    for (t, v) in zip(timestamps, values) {
        series.push(t: Int64(t), v: v)
    }
    series.finish()

    return series.bytes.map { Int($0) }
}

/// Decompress Gorilla TSZ bytes into (timestamp, value) pairs.
///
/// - Parameter data: Compressed bytes as a list of integers (0-255)
/// - Returns: List of [timestamp, value] pairs
@PyFunction
func decompress(data: [Int]) throws -> [[Double]] {
    let bytes = data.map { UInt8($0 & 0xFF) }
    guard var iter = Iterator(bytes: bytes) else {
        throw PygorillaError.invalidData("Cannot create iterator from data")
    }

    var result: [[Double]] = []
    while iter.next() {
        let (t, v) = iter.values()
        result.append([Double(t), v])
    }

    if iter.hasError {
        throw PygorillaError.decompressError("Error during decompression")
    }

    return result
}

/// Get compression statistics for a time series.
@PyFunction
func compression_stats(t0: Int, timestamps: [Int], values: [Double]) throws -> [String: Double] {
    guard timestamps.count == values.count else {
        throw PygorillaError.mismatchedLengths(
            "timestamps has \(timestamps.count) elements but values has \(values.count)")
    }

    var series = Series(t0: Int64(t0))
    for (t, v) in zip(timestamps, values) {
        series.push(t: Int64(t), v: v)
    }
    series.finish()

    let rawBytes = Double(timestamps.count * 16)  // 8 bytes timestamp + 8 bytes value
    let compressedBytes = Double(series.bytes.count)

    return [
        "raw_bytes": rawBytes,
        "compressed_bytes": compressedBytes,
        "ratio": rawBytes / compressedBytes,
        "count": Double(timestamps.count),
    ]
}

// MARK: - Errors

enum PygorillaError: Error {
    case mismatchedLengths(String)
    case invalidData(String)
    case decompressError(String)
}

// MARK: - Module Entry Point

@PyModule("pygorilla", functions: [
    compress,
    decompress,
    compression_stats,
])
func pygorilla() {}

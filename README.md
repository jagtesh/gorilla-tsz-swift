# GorillaTSZ

A Swift implementation of Facebook's [Gorilla](http://www.vldb.org/pvldb/vol8/p1816-teller.pdf) time-series compression algorithm.

Inspired by and ported from [dgryski/go-tsz](https://github.com/dgryski/go-tsz), the most established open-source implementation of the Gorilla algorithm. Test data and algorithm semantics follow the Go reference project.

## Compression

| Dataset | Raw | Compressed | Ratio |
|---------|-----|------------|-------|
| 120 real data points (2h, 60s interval) | 1,440 B | 202 B | **7.1x** |
| 100 identical values (constant interval) | 1,200 B | 44 B | **27.3x** |

## Usage

```swift
import GorillaTSZ

// Compress
var series = Series(t0: blockStartTimestamp)
series.push(t: 1000, v: 42.5)
series.push(t: 1060, v: 43.1)
series.push(t: 1120, v: 42.8)
series.finish()

let compressed = series.bytes  // [UInt8]

// Decompress
var iter = Iterator(bytes: compressed)!
while iter.next() {
    let (timestamp, value) = iter.values()
    print("\(timestamp): \(value)")
}
```

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/jagtesh/gorilla-tsz-swift.git", from: "0.1.0"),
]
```

## Algorithm

- **Timestamps**: Delta-of-delta encoding with variable-length bit packing
- **Values**: XOR with previous value, leading/trailing zero compression
- **Lossless**: Exact roundtrip for all Float64 values including ±Infinity

## API

### `Series` (Compressor)
- `init(t0: UInt32)` — create with block header timestamp
- `push(t: UInt32, v: Float64)` — add a data point
- `finish()` — write end-of-stream marker
- `bytes: [UInt8]` — compressed output

### `Iterator` (Decompressor)
- `init?(bytes: [UInt8])` — create from compressed bytes
- `next() -> Bool` — advance to next point
- `values() -> (timestamp: UInt32, value: Float64)` — current point

### `BitStream`
- Variable-length bit reader/writer with MSB-first packing
- Index-based reading (no array mutation overhead)

## Python Bindings

This package includes **[pygorilla](pygorilla/)**, a Python wrapper powered by [ApplePy](https://github.com/jagtesh/applepy) that calls directly into the Swift-native implementation.

```python
import pygorilla

compressed = pygorilla.compress(1440583200, [1440583260, 1440583320], [761.0, 727.0])
points = pygorilla.decompress(compressed)  # [(1440583260.0, 761.0), ...]
stats = pygorilla.compression_stats(1440583200, timestamps, values)
```

```bash
cd pygorilla && applepy develop  # build & install into current Python env
```

See [pygorilla/README.md](pygorilla/README.md) for full API documentation.

## License

BSD-3-Clause

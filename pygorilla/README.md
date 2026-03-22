# pygorilla

Fast, lossless time-series compression using Facebook's [Gorilla](http://www.vldb.org/pvldb/vol8/p1816-teller.pdf) algorithm.

Powered by a Swift-native implementation for maximum performance. Inspired by [dgryski/go-tsz](https://github.com/dgryski/go-tsz).

## Installation

### From source (requires Swift toolchain + [ApplePy](https://github.com/jagtesh/applepy))

```bash
git clone https://github.com/jagtesh/gorilla-tsz-swift.git
cd gorilla-tsz-swift/pygorilla
applepy develop       # builds Swift → .so and installs into current env
```

### From PyPI (coming soon)

```bash
pip install pygorilla
```

## Quick Start

```python
import pygorilla

# Timestamps (epoch seconds) and values
t0 = 1440583200
timestamps = [t0 + 60 * i for i in range(1, 121)]  # 120 points, 60s apart
values = [761, 727, 765, 706, 700, 679, 757, 708, 739, 707] * 12

# Compress
compressed = pygorilla.compress(t0, timestamps, values)

# Decompress
points = pygorilla.decompress(compressed)
for ts, val in points:
    print(f"  t={int(ts)}, v={val}")

# Get stats
stats = pygorilla.compression_stats(t0, timestamps, values)
print(f"Ratio: {stats['ratio']:.1f}x")
```

## API Reference

### `compress(t0, timestamps, values) → list[int]`

Compress a time series into Gorilla TSZ format.

| Parameter | Type | Description |
|-----------|------|-------------|
| `t0` | `int` | Block header timestamp (epoch seconds) |
| `timestamps` | `list[int]` | Monotonically increasing timestamps |
| `values` | `list[float]` | Corresponding float64 values |

**Returns:** Compressed bytes as `list[int]` (values 0–255).

### `decompress(data) → list[tuple[float, float]]`

Decompress Gorilla TSZ bytes back into data points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `list[int]` | Compressed bytes from `compress()` |

**Returns:** List of `(timestamp, value)` tuples.

### `compression_stats(t0, timestamps, values) → dict[str, float]`

Get compression ratio and byte counts without storing the result.

**Returns:** Dictionary with keys: `raw_bytes`, `compressed_bytes`, `ratio`, `count`.

## Compression Performance

| Dataset | Raw | Compressed | Ratio |
|---------|-----|------------|-------|
| 120 points (2h, 60s interval) | 1,440 B | 202 B | **7.1×** |
| 100 identical values | 1,200 B | 44 B | **27.3×** |
| 10 varied points | 120 B | 37 B | **3.2×** |

## How It Works

Gorilla TSZ uses two complementary techniques:

- **Timestamps:** Delta-of-delta encoding with variable-length bit packing. Constant-interval data (e.g., sensor readings) compresses to ~1 bit per timestamp.
- **Values:** XOR with previous value, then leading/trailing zero compression. Similar consecutive values compress to 1–2 bits.

The compression is **lossless** — all `float64` values (including ±Infinity, NaN, subnormals) roundtrip exactly.

## Architecture

```
Python (pygorilla)
    ↓ ApplePy FFI
Swift (GorillaTSZ library)
    ↓ native bit manipulation
Compressed byte stream
```

The heavy lifting runs in compiled Swift. Python is just the interface layer.

## Requirements

- Python ≥ 3.10
- Swift toolchain ≥ 5.9
- [ApplePy](https://github.com/jagtesh/applepy) (for building from source)

## License

BSD-3-Clause

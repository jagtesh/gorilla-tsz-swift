#!/usr/bin/env python3
"""pygorilla — Example Usage"""
import pygorilla

# Compress a time series
t0 = 1440583200  # block header timestamp
timestamps = [t0 + 60 * i for i in range(1, 11)]  # 10 points, 60s apart
values = [761.0, 727.0, 765.0, 706.0, 700.0, 679.0, 757.0, 708.0, 739.0, 707.0]

compressed = pygorilla.compress(t0, timestamps, values)
print(f"Compressed {len(values)} points into {len(compressed)} bytes")

# Decompress
points = pygorilla.decompress(compressed)
print(f"Decompressed {len(points)} points:")
for ts, val in points:
    print(f"  t={int(ts)}, v={val}")

# Stats
stats = pygorilla.compression_stats(t0, timestamps, values)
print(f"\nCompression ratio: {stats['ratio']:.1f}x "
      f"({int(stats['raw_bytes'])}B → {int(stats['compressed_bytes'])}B)")

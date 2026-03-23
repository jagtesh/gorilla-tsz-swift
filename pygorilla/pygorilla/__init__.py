"""pygorilla — Fast, lossless time-series compression.

Python bindings for Gorilla TSZ, Facebook's time-series compression algorithm.
Powered by a Swift-native implementation via ApplePy for maximum performance.

Basic usage::

    import pygorilla

    # Compress
    compressed = pygorilla.compress(1000, [1060, 1120, 1180], [42.5, 43.1, 42.8])

    # Decompress
    points = pygorilla.decompress(compressed)
    # [(1060, 42.5), (1120, 43.1), (1180, 42.8)]

    # Get compression statistics
    stats = pygorilla.compression_stats(1000, timestamps, values)
    # {'ratio': 7.1, 'raw_bytes': 1440, 'compressed_bytes': 202, ...}

Functions:
    compress(t0, timestamps, values) -> list[int]
        Compress a time series into Gorilla TSZ format.

    decompress(data) -> list[list[float]]
        Decompress Gorilla TSZ bytes into (timestamp, value) pairs.

    compression_stats(t0, timestamps, values) -> dict[str, float]
        Get compression ratio and byte counts for a time series.
"""
import importlib
import os
import sys


def _load_native():
    """Load the compiled Swift extension module."""
    pkg_dir = os.path.dirname(os.path.abspath(__file__))
    so_path = os.path.join(pkg_dir, "_native", "pygorilla.so")

    if not os.path.exists(so_path):
        raise ImportError(
            "Native extension not found. Build it first:\n"
            "  cd pygorilla && applepy develop\n"
            "  # or: pip install -e ."
        )

    spec = importlib.util.spec_from_file_location(
        "pygorilla._native.pygorilla", so_path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


_native = _load_native()

# --- Public API ---

def compress(t0: int, timestamps: list[int], values: list[float]) -> list[int]:
    """Compress a time series into Gorilla TSZ format.

    Args:
        t0: Block header timestamp (epoch seconds, uint32 range).
        timestamps: Monotonically increasing timestamps (epoch seconds).
        values: Corresponding float64 values.

    Returns:
        Compressed bytes as a list of integers (0–255).

    Raises:
        ValueError: If timestamps and values have different lengths.

    Example::

        compressed = pygorilla.compress(
            1440583200,
            [1440583260, 1440583320, 1440583380],
            [761.0, 727.0, 765.0]
        )
    """
    return _native.compress(t0, timestamps, values)


def decompress(data: list[int]) -> list[tuple[float, float]]:
    """Decompress Gorilla TSZ bytes into (timestamp, value) pairs.

    Args:
        data: Compressed bytes as a list of integers (0–255),
              as returned by :func:`compress`.

    Returns:
        List of (timestamp, value) tuples.

    Raises:
        RuntimeError: If the data is corrupt or cannot be decoded.

    Example::

        points = pygorilla.decompress(compressed)
        for ts, val in points:
            print(f"t={int(ts)}, v={val}")
    """
    return [(row[0], row[1]) for row in _native.decompress(data)]


def compression_stats(
    t0: int, timestamps: list[int], values: list[float]
) -> dict[str, float]:
    """Get compression statistics for a time series.

    Args:
        t0: Block header timestamp (epoch seconds).
        timestamps: Monotonically increasing timestamps.
        values: Corresponding float64 values.

    Returns:
        Dictionary with keys:
            - ``raw_bytes``: Uncompressed size (4 + 8 bytes per point).
            - ``compressed_bytes``: Gorilla TSZ compressed size.
            - ``ratio``: Compression ratio (raw / compressed).
            - ``count``: Number of data points.

    Example::

        stats = pygorilla.compression_stats(
            1440583200,
            [1440583260, 1440583320],
            [761.0, 727.0]
        )
        print(f"Ratio: {stats['ratio']:.1f}x")
    """
    return _native.compression_stats(t0, timestamps, values)


__all__ = ["compress", "decompress", "compression_stats"]
__version__ = "0.1.0"

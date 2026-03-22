# Pygorilla

Python bindings for Gorilla TSZ time-series compression (Swift-native)

> **macOS only** — requires Swift 6.0+ and ApplePy

## Install

```bash
applepy develop
# or: pip install -e .
```

## Usage

```python
import pygorilla

print(pygorilla.hello("World"))  # Hello, World! 🍎
```

## Development

```bash
applepy develop    # Build Swift + install
applepy build      # Build wheel
applepy publish    # Publish to PyPI
```

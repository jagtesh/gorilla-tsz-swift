"""pygorilla — Python bindings for Gorilla TSZ time-series compression (Swift-native)

Powered by Swift & ApplePy.
"""
import importlib
import os
import sys




def _load_native():
    """Load the compiled Swift extension module."""
    pkg_dir = os.path.dirname(os.path.abspath(__file__))
    so_path = os.path.join(pkg_dir, "pygorilla.so")

    if not os.path.exists(so_path):
        raise ImportError(
            "Native extension not found. Build it first:\n"
            "  applepy develop\n"
            "  # or: pip install -e ."
        )

    spec = importlib.util.spec_from_file_location("pygorilla", so_path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


_native = _load_native()

# Re-export all public attributes from the native module
for _attr in dir(_native):
    if not _attr.startswith("_"):
        globals()[_attr] = getattr(_native, _attr)

__version__ = "0.1.0"

# Installation

## Requirements

- Python 3.8 or higher
- pip (Python package manager)

Note: `qcrypto` relies on the Open Quantum Safe `liboqs` native library.
On some platforms, the `liboqs` shared library must be installed separately.

---

## Install from PyPI

```bash
pip install qcrypto
```

This installs the Python dependencies:

- `liboqs-python` (Python bindings for Open Quantum Safe)
- `cryptography` (AES-GCM encryption and key derivation)

---

## Verify Installation

```bash
python -c "import qcrypto; print('qcrypto installed successfully')"
```

Or test the CLI:

```bash
qcrypto --help
```

---

## Install from Source

```bash
git clone https://github.com/victorpostea/qcrypto.git
cd qcrypto
pip install -e .
```

---

## Platform Notes

### macOS

Usually works out of the box on Apple Silicon and Intel Macs.

If you encounter errors related to `liboqs`, install it with Homebrew:

```bash
brew install liboqs
```

---

### Linux

On Linux, `qcrypto` installs the Python bindings (`liboqs-python`), but the
`liboqs` shared library (`liboqs.so`) may need to be installed separately.

If you see an error like:

```
RuntimeError: No oqs shared libraries found
```

Build and install `liboqs` from source:

```bash
sudo apt update
sudo apt install -y git cmake ninja-build build-essential libssl-dev

git clone https://github.com/open-quantum-safe/liboqs
cd liboqs
git fetch --tags
git checkout 0.14.0

cmake -S . -B build -GNinja \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX=$HOME/.local

cmake --build build
cmake --install build
```

Ensure the shared library can be found at runtime:

```bash
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
```

To make this permanent:

```bash
echo 'export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### Windows

Not officially supported at this time.

If you want to experiment with `qcrypto` on Windows, use WSL2
(Windows Subsystem for Linux).

---

## Available Algorithms

The available algorithms depend on your `liboqs` build.

To list supported algorithms:

```python
import oqs

print("KEMs:", oqs.get_enabled_KEM_mechanisms())
print("Signatures:", oqs.get_enabled_sig_mechanisms())
```

Or via the command line:

```bash
python -c "import oqs; print('\n'.join(oqs.get_enabled_KEM_mechanisms()))"
```

---

## Troubleshooting

### `ModuleNotFoundError: No module named 'oqs'`

The Python bindings were not installed correctly. Try:

```bash
pip install --force-reinstall liboqs-python
```

---

### `RuntimeError: No oqs shared libraries found`

The `liboqs` shared library is missing or not discoverable by the dynamic
linker. Install `liboqs` and ensure it is on your library path
(`LD_LIBRARY_PATH` on Linux).

---

### Algorithm not available

Your `liboqs` build may not include all algorithms.
The standard `liboqs` release includes all NIST-selected algorithms.

---

### Permission errors on key files

The CLI creates key material with restricted permissions (0600).
Ensure you have write access to:

```
~/.qcrypto/
```

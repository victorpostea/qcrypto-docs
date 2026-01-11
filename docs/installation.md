# Installation

## Requirements

- Python 3.8 or higher
- pip (Python package manager)

## Install from PyPI

```bash
pip install qcrypto
```

This automatically installs:

- `liboqs-python` — Open Quantum Safe Python bindings
- `cryptography` — For AES-GCM and key derivation

## Verify Installation

```bash
python -c "import qcrypto; print('qcrypto installed successfully')"
```

Or test the CLI:

```bash
qcrypto --help
```

## Install from Source

```bash
git clone https://github.com/victorpostea/qcrypto.git
cd qcrypto
pip install -e .
```

## Platform Notes

### macOS

Works out of the box on Apple Silicon and Intel Macs.

### Linux

Requires a C compiler for liboqs. On Ubuntu/Debian:

```bash
sudo apt-get install build-essential cmake
pip install qcrypto
```

### Windows

Pre-built wheels are available. If installation fails, install Visual Studio Build Tools first.

## Available Algorithms

The algorithms available depend on your liboqs build. To see what's available:

```python
import oqs

print("KEMs:", oqs.get_enabled_KEM_mechanisms())
print("Signatures:", oqs.get_enabled_sig_mechanisms())
```

Or use the CLI:

```bash
python -c "import oqs; print('\n'.join(oqs.get_enabled_KEM_mechanisms()))"
```

## Troubleshooting

### `ModuleNotFoundError: No module named 'oqs'`

The liboqs-python package didn't install correctly. Try:

```bash
pip install --force-reinstall liboqs-python
```

### Algorithm not available

Your liboqs build may not include all algorithms. The standard pip install includes all NIST-selected algorithms.

### Permission errors on key files

The CLI creates keys with restricted permissions (0600). Ensure you have write access to `~/.qcrypto/`.

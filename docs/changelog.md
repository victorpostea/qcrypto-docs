# Changelog

All notable changes to qcrypto are documented here.

---

## v1.0.0 — Stable Release

**Released:** January 2026

This release marks qcrypto as stable for experimental and research use.

- All features from v0.5.0 are stable and tested
- No breaking API changes from v0.5.0
- Comprehensive documentation site

---

## v0.5.0 — Complete PQC Toolkit

**Released:** January 2026

### Key Discovery & Default Keypaths

Keys are now automatically discovered at default locations:

- `~/.qcrypto/kem/private.key` and `~/.qcrypto/kem/public.key` for encryption
- `~/.qcrypto/sig/private.key` and `~/.qcrypto/sig/public.key` for signatures

This follows conventions from OpenSSH (`~/.ssh/`), age, and GPG.

### ASCII-Armored Key Format

Human-readable, copy/paste friendly keys and messages:

```
-----BEGIN QCRYPTO PRIVATE KEY-----
(base64 payload)
-----END QCRYPTO PRIVATE KEY-----
```

```
-----BEGIN QCRYPTO MESSAGE-----
(base64 payload)
-----END QCRYPTO MESSAGE-----
```

Use `--armored` flag in CLI or `encoding="armor"` in Python.

### Digital Signatures via CLI

New `qcrypto sign` and `qcrypto verify` commands:

```bash
qcrypto sign --key priv.key --in message.txt --out message.sig
qcrypto verify --pub pub.key --in message.txt --sig message.sig
```

Supports Dilithium, Falcon, and SPHINCS+ algorithms.

### Key Fingerprints

Stable key identity derived from public key:

```python
from qcrypto import key_fingerprint
fp = key_fingerprint(public_key)  # SHA256(pubkey)[:16] as hex
```

Fingerprints are displayed in CLI output for verification.

### Header Checksums

Ciphertext format v2 includes CRC32 checksum for nicer error messages:

- Detects corrupted headers
- Distinguishes wrong algorithm from file corruption
- Identifies truncated files early

### Other Improvements

- Full CLI with `gen-key`, `encrypt`, `decrypt`, `sig-gen-key`, `sign`, `verify`
- Passphrase-protected private keys (PBKDF2-HMAC-SHA256 + AES-GCM)
- Interactive passphrase prompting
- `encrypt_message_armored()` and `decrypt_message_armored()` helpers

---

## v0.4.0 — File Encryption & Streaming AES-GCM

**Released:** December 2025

### New Features

- Added `encrypt_file()` and `decrypt_file()` for real file encryption workflows
- Introduced streaming AES-256-GCM, allowing encryption/decryption of large files without loading the entire file into memory
- File ciphertext format matches the existing `encrypt()` API for full compatibility

### Ciphertext Format

```
[1 byte]    version
[1 byte]    algorithm id
[2 bytes]   Kyber ciphertext length
[N bytes]   Kyber ciphertext
[12 bytes]  AES-GCM nonce
[M bytes]   AES-GCM ciphertext + 16-byte GCM tag
```

### Other Improvements

- Added round-trip file encryption tests
- Updated `__init__.py` to expose file encryption helpers
- Internal refactoring to support chunked I/O

---

## v0.3.0 — Expanded PQC Support

**Released:** December 2025

### New Algorithms

- Falcon signatures (`FalconSig`)
- SPHINCS+ signatures (`SphincsSig`)
- Classic McEliece KEM (`ClassicMcElieceKEM`)

### Unified Signature Interface

- Added `SignatureScheme` supporting any liboqs signature algorithm

### Examples

- Added Falcon, SPHINCS+, McEliece, and generic signature examples

### Internal Improvements

- Restructured signatures/KEMs for easier future expansion

---

## v0.2.0 — Hybrid API Rewrite

**Released:** November 2025

- Added new high-level hybrid `encrypt()` and `decrypt()`
- Introduced standardized single-blob ciphertext format
- Added key serialization helpers
- Improved decapsulation API
- Legacy API preserved for compatibility

---

## v0.1.0 — Initial Release

**Released:** October 2025

- Kyber KEM support
- Dilithium signature support
- Basic hybrid encryption with `encrypt_for_recipient()` / `decrypt_from_sender()`

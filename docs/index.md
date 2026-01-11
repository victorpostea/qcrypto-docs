# qcrypto

**Post-quantum cryptography for Python — simple, Pythonic, and ready for the quantum era.**

![Version](https://img.shields.io/badge/version-1.0.0-green)
![Python](https://img.shields.io/badge/python-3.8+-blue)

---

## What is qcrypto?

**qcrypto** is a lightweight Python library that provides simple wrappers around post-quantum cryptography (PQC) using the official [liboqs-python](https://github.com/open-quantum-safe/liboqs-python) bindings from the Open Quantum Safe project.

```python
from qcrypto import KyberKEM, encrypt, decrypt

# Generate a quantum-safe keypair
kem = KyberKEM("Kyber768")
keys = kem.generate_keypair()

# Encrypt a message
ciphertext = encrypt(keys.public_key, b"Hello, quantum world!")

# Decrypt it
plaintext = decrypt(keys.private_key, ciphertext)
```

---

## Features

### 🔐 Hybrid Encryption

Kyber KEM + HKDF + AES-256-GCM for authenticated encryption that's secure against both classical and quantum attacks.

### ✍️ Digital Signatures

Support for Dilithium, Falcon, and SPHINCS+ — all NIST-selected PQC signature algorithms.

### 🔑 Key Management

ASCII-armored keys, passphrase protection, fingerprints, and sensible default paths like `~/.qcrypto/`.

### 💻 Full CLI

Complete command-line toolkit for key generation, encryption, decryption, signing, and verification.

---

## Supported Algorithms

### Key Encapsulation (KEM)

| Algorithm | Security Level | Status |
|-----------|---------------|--------|
| **Kyber** (512, 768, 1024) | 128–256 bit | ✅ NIST Standard |
| **Classic McEliece** | 128–256 bit | ✅ NIST Finalist |

### Digital Signatures

| Algorithm | Security Level | Status |
|-----------|---------------|--------|
| **Dilithium** (2, 3, 5) | 128–256 bit | ✅ NIST Standard |
| **Falcon** (512, 1024) | 128–256 bit | ✅ NIST Standard |
| **SPHINCS+** | 128–256 bit | ✅ NIST Standard |

---

## Quick Install

```bash
pip install qcrypto
```

That's it — `liboqs-python` and all dependencies install automatically.

---

## Quick Start

### Generate Keys

=== "CLI"

    ```bash
    qcrypto gen-key --armored
    ```

=== "Python"

    ```python
    from qcrypto import KyberKEM

    kem = KyberKEM("Kyber768")
    keys = kem.generate_keypair()
    kem.save_public_key("my.pub", encoding="armor")
    kem.save_private_key("my.key", encoding="armor")
    ```

### Encrypt a File

=== "CLI"

    ```bash
    qcrypto encrypt --in secret.txt --out secret.enc
    ```

=== "Python"

    ```python
    from qcrypto import encrypt_file, KyberKEM

    pub = KyberKEM.load_public_key("my.pub")
    encrypt_file(pub, "secret.txt", "secret.enc")
    ```

### Sign a Document

=== "CLI"

    ```bash
    qcrypto sig-gen-key --alg Dilithium3
    qcrypto sign --in contract.pdf --out contract.sig
    ```

=== "Python"

    ```python
    from qcrypto import SignatureScheme

    scheme = SignatureScheme("Dilithium3")
    keys = scheme.generate_keypair()
    signature = scheme.sign(keys.secret_key, document_bytes)
    ```

---

## Why Post-Quantum?

Quantum computers threaten today's encryption. Algorithms like RSA and ECC can be broken by Shor's algorithm running on a sufficiently powerful quantum computer.

**qcrypto** uses NIST-standardized algorithms designed to resist both classical and quantum attacks:

- **Kyber** — Lattice-based KEM, fast and compact
- **Dilithium** — Lattice-based signatures, efficient and small
- **Falcon** — Lattice-based signatures, very compact
- **SPHINCS+** — Hash-based signatures, conservative security

Start protecting your data today for the quantum future.

---

## Disclaimer

!!! warning "For Research & Experimentation"
    
    This library is for educational, experimental, and research use. It has not undergone formal security review and should not be used in production systems requiring certified cryptographic implementations.

---

## Resources

- [Open Quantum Safe](https://openquantumsafe.org) — The PQC project behind liboqs
- [liboqs-python](https://github.com/open-quantum-safe/liboqs-python) — Python bindings
- [NIST PQC](https://csrc.nist.gov/projects/post-quantum-cryptography) — Standardization project

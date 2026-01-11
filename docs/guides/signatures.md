# Digital Signatures Guide

qcrypto supports three NIST-selected post-quantum signature algorithms: **Dilithium**, **Falcon**, and **SPHINCS+**.

## Choosing an Algorithm

| Algorithm | Public Key | Signature | Speed | Best For |
|-----------|-----------|-----------|-------|----------|
| **Dilithium3** | 1,952 B | 3,293 B | Fast | General purpose |
| **Falcon-512** | 897 B | ~690 B | Fast | Size-constrained |
| **SPHINCS+-128f** | 32 B | 17,088 B | Slow | Conservative security |

**Recommendations:**

- **Dilithium3** — Best all-around choice, good balance
- **Falcon-512** — When signature size matters most
- **SPHINCS+** — When you want hash-based (conservative) security

## Basic Usage

### Sign and Verify

```python
from qcrypto import SignatureScheme

# Create scheme
scheme = SignatureScheme("Dilithium3")
keys = scheme.generate_keypair()

# Sign
message = b"This document is authentic."
signature = scheme.sign(keys.secret_key, message)

# Verify
valid = scheme.verify(keys.public_key, message, signature)
print(f"Signature valid: {valid}")  # True
```

### Using Convenience Wrappers

```python
from qcrypto import DilithiumSig, FalconSig, SphincsSig

# Dilithium
dilithium = DilithiumSig("Dilithium3")
keys = dilithium.generate_keypair()

# Falcon
falcon = FalconSig("Falcon-512")
keys = falcon.generate_keypair()

# SPHINCS+
sphincs = SphincsSig("SPHINCS+-SHA2-128f-simple")
keys = sphincs.generate_keypair()
```

## Key Management

### Save and Load Keys

```python
from qcrypto import (
    SignatureScheme,
    save_signature_public_key,
    save_signature_private_key,
    load_signature_public_key,
    load_signature_private_key,
)

# Generate
scheme = SignatureScheme("Dilithium3")
keys = scheme.generate_keypair()

# Save (armored, with passphrase)
save_signature_public_key("signing.pub", keys.public_key, "Dilithium3", armored=True)
save_signature_private_key("signing.key", keys.secret_key, "Dilithium3", 
                           armored=True, passphrase="secret")

# Load
alg, pub = load_signature_public_key("signing.pub")
alg, priv = load_signature_private_key("signing.key", passphrase="secret")
```

### Save and Load Signatures

```python
from qcrypto import save_signature, load_signature

# Save signature
save_signature("document.sig", signature, "Dilithium3", armored=True)

# Load signature
alg, sig_bytes = load_signature("document.sig")
```

## CLI Usage

### Generate Signature Keys

```bash
# Dilithium (default)
qcrypto sig-gen-key

# Falcon with passphrase
qcrypto sig-gen-key --alg Falcon-512 --pass --armored

# SPHINCS+
qcrypto sig-gen-key --alg "SPHINCS+-SHA2-128f-simple"
```

### Sign Files

```bash
# Sign with default key
qcrypto sign --in contract.pdf --out contract.sig

# Sign with armored signature
qcrypto sign --in message.txt --out message.sig --armored

# Sign with passphrase-protected key
qcrypto sign --pass --in document.pdf --out document.sig
```

### Verify Signatures

```bash
# Verify with default key
qcrypto verify --in contract.pdf --sig contract.sig
# OK: signature valid

# Verify with specific public key
qcrypto verify --pub author.pub --in message.txt --sig message.sig
```

## Signature File Format

qcrypto signatures are self-describing:

```
┌──────────────────────────────────────────────────────────┐
│ Magic         │ "qcrypto-signature-v1\n"                 │
├───────────────┼──────────────────────────────────────────┤
│ 2 bytes       │ Algorithm name length (big-endian)       │
├───────────────┼──────────────────────────────────────────┤
│ N bytes       │ Algorithm name (UTF-8)                   │
├───────────────┼──────────────────────────────────────────┤
│ Remaining     │ Raw signature bytes                      │
└───────────────┴──────────────────────────────────────────┘
```

When armored:

```
-----BEGIN QCRYPTO SIGNATURE-----
(base64 encoded content)
-----END QCRYPTO SIGNATURE-----
```

## Available Algorithms

### Dilithium

| Variant | Security Level | Public Key | Signature |
|---------|----------------|------------|-----------|
| Dilithium2 | NIST Level 2 | 1,312 B | 2,420 B |
| Dilithium3 | NIST Level 3 | 1,952 B | 3,293 B |
| Dilithium5 | NIST Level 5 | 2,592 B | 4,595 B |

### Falcon

| Variant | Security Level | Public Key | Signature |
|---------|----------------|------------|-----------|
| Falcon-512 | NIST Level 1 | 897 B | ~690 B |
| Falcon-1024 | NIST Level 5 | 1,793 B | ~1,330 B |

### SPHINCS+

SPHINCS+ has many parameter sets. Common ones:

| Variant | Type | Public Key | Signature |
|---------|------|------------|-----------|
| SPHINCS+-SHA2-128f-simple | Fast | 32 B | 17,088 B |
| SPHINCS+-SHA2-128s-simple | Small | 32 B | 7,856 B |
| SPHINCS+-SHA2-256f-simple | Fast | 64 B | 49,856 B |

## Security Considerations

!!! tip "Key Storage"
    
    Always protect signature private keys with passphrases for production use:
    ```bash
    qcrypto sig-gen-key --pass --armored
    ```

!!! warning "Signature Binding"
    
    Signatures only prove the message wasn't modified. They don't bind to context like timestamps or recipients. Include that data in the signed message if needed.

!!! info "Algorithm Agility"
    
    qcrypto signatures include the algorithm name, making it safe to use different algorithms over time. Old signatures remain verifiable.

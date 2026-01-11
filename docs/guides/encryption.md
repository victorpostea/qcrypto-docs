# Hybrid Encryption Guide

qcrypto uses **hybrid encryption**: a post-quantum KEM (Kyber) establishes a shared secret, which is then used with classical AES-256-GCM for authenticated encryption.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                      Encryption                              │
├─────────────────────────────────────────────────────────────┤
│  1. Kyber encapsulates → ciphertext + shared_secret         │
│  2. HKDF-SHA256 derives AES key from shared_secret          │
│  3. AES-256-GCM encrypts plaintext                          │
│  4. Output: header + kyber_ct + nonce + aes_ciphertext      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      Decryption                              │
├─────────────────────────────────────────────────────────────┤
│  1. Parse header, extract Kyber ciphertext                  │
│  2. Kyber decapsulates → shared_secret                      │
│  3. HKDF-SHA256 derives same AES key                        │
│  4. AES-256-GCM decrypts and verifies                       │
└─────────────────────────────────────────────────────────────┘
```

## Basic Usage

### Encrypt/Decrypt Bytes

```python
from qcrypto import KyberKEM, encrypt, decrypt

# Setup
kem = KyberKEM("Kyber768")
keys = kem.generate_keypair()

# Encrypt
plaintext = b"Sensitive data"
ciphertext = encrypt(keys.public_key, plaintext)

# Decrypt
recovered = decrypt(keys.private_key, ciphertext)
assert recovered == plaintext
```

### Encrypt/Decrypt Files

For large files, use streaming encryption which doesn't load the entire file into memory:

```python
from qcrypto import encrypt_file, decrypt_file, KyberKEM

# Load keys
pub = KyberKEM.load_public_key("recipient.pub")
priv = KyberKEM.load_private_key("my.key")

# Encrypt a file (streaming)
encrypt_file(pub, "large_video.mp4", "large_video.mp4.enc")

# Decrypt a file (streaming)
decrypt_file(priv, "large_video.mp4.enc", "large_video.mp4")
```

### Armored Messages

For email or chat, use ASCII-armored encoding:

```python
from qcrypto import encrypt_message_armored, decrypt_message_armored

# Encrypt to armored format
armored = encrypt_message_armored(pub, b"Secret message")
print(armored)
# -----BEGIN QCRYPTO MESSAGE-----
# AgEEQJg/+TQjIxlLvaPaBU5VKaXS...
# -----END QCRYPTO MESSAGE-----

# Decrypt armored message
plaintext = decrypt_message_armored(priv, armored)
```

## Ciphertext Format

qcrypto uses a self-describing binary format:

```
┌──────────────────────────────────────────────────────────┐
│ Byte 0      │ Version (currently 2)                      │
├─────────────┼────────────────────────────────────────────┤
│ Byte 1      │ Algorithm ID (1 = Kyber768)                │
├─────────────┼────────────────────────────────────────────┤
│ Bytes 2-3   │ Kyber ciphertext length (big-endian)       │
├─────────────┼────────────────────────────────────────────┤
│ Bytes 4-7   │ CRC32 checksum of header (v2)              │
├─────────────┼────────────────────────────────────────────┤
│ N bytes     │ Kyber ciphertext                           │
├─────────────┼────────────────────────────────────────────┤
│ 12 bytes    │ AES-GCM nonce                              │
├─────────────┼────────────────────────────────────────────┤
│ M bytes     │ AES-GCM ciphertext + 16-byte tag           │
└─────────────┴────────────────────────────────────────────┘
```

The header checksum (v2) provides helpful error messages for corrupted files.

## Key Management

### Generate Keys

```python
kem = KyberKEM("Kyber768")
keys = kem.generate_keypair()

# Save keys
kem.save_public_key("my.pub", encoding="armor")
kem.save_private_key("my.key", encoding="armor", passphrase="secret")
```

### Load Keys

```python
# Load public key (auto-detects armor)
pub = KyberKEM.load_public_key("my.pub")

# Load private key with passphrase
priv = KyberKEM.load_private_key("my.key", passphrase="secret")
```

### Key Fingerprints

Fingerprints help verify key identity:

```python
from qcrypto import key_fingerprint

fp = key_fingerprint(pub)
print(f"Key: {fp}")  # "a1b2c3d4e5f67890..."
```

## Security Considerations

!!! success "What qcrypto provides"
    
    - **Post-quantum security** via Kyber768 (NIST Level 3)
    - **Authenticated encryption** via AES-256-GCM
    - **Forward secrecy** per-message (fresh encapsulation)
    - **Integrity protection** for header and payload

!!! warning "What qcrypto does NOT provide"
    
    - Key exchange protocols
    - Identity verification (no PKI)
    - Replay protection (application responsibility)
    - Metadata hiding (file sizes visible)

## Algorithm Details

| Component | Algorithm | Security Level |
|-----------|-----------|----------------|
| KEM | Kyber768 | NIST Level 3 (~AES-192) |
| KDF | HKDF-SHA256 | 256-bit |
| AEAD | AES-256-GCM | 256-bit |
| Nonce | Random 96-bit | Per-message |

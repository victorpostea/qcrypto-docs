# Hybrid Encryption API Reference

High-level encryption functions combining Kyber KEM with AES-256-GCM.

## encrypt

Encrypt data using hybrid PQC + AES-GCM.

```python
from qcrypto import encrypt

def encrypt(public_key: bytes, plaintext: bytes) -> bytes
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `public_key` | `bytes` | Recipient's Kyber public key |
| `plaintext` | `bytes` | Data to encrypt |

**Returns:** Ciphertext bytes (header + Kyber CT + nonce + AES ciphertext + tag).

**Example:**

```python
from qcrypto import KyberKEM, encrypt

pub = KyberKEM.load_public_key("recipient.pub")
ciphertext = encrypt(pub, b"Secret message")
```

---

## decrypt

Decrypt data encrypted with `encrypt()`.

```python
from qcrypto import decrypt

def decrypt(private_key: bytes, ciphertext: bytes) -> bytes
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `private_key` | `bytes` | Recipient's Kyber private key |
| `ciphertext` | `bytes` | Ciphertext from `encrypt()` |

**Returns:** Original plaintext bytes.

**Raises:**

- `ValueError` — Invalid header, wrong algorithm, corrupted data
- `cryptography.exceptions.InvalidTag` — Authentication failed

**Example:**

```python
from qcrypto import KyberKEM, decrypt

priv = KyberKEM.load_private_key("my.key", passphrase="secret")
plaintext = decrypt(priv, ciphertext)
```

---

## encrypt_file

Encrypt a file with streaming I/O.

```python
from qcrypto import encrypt_file

def encrypt_file(
    public_key: bytes,
    input_path: str,
    output_path: str,
    chunk_size: int = 65536
) -> None
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `public_key` | `bytes` | - | Recipient's public key |
| `input_path` | `str` | - | Path to plaintext file |
| `output_path` | `str` | - | Path for encrypted output |
| `chunk_size` | `int` | `65536` | Streaming chunk size (bytes) |

**Example:**

```python
from qcrypto import encrypt_file, KyberKEM

pub = KyberKEM.load_public_key("recipient.pub")
encrypt_file(pub, "large_video.mp4", "large_video.mp4.enc")
```

---

## decrypt_file

Decrypt a file encrypted with `encrypt_file()`.

```python
from qcrypto import decrypt_file

def decrypt_file(
    private_key: bytes,
    input_path: str,
    output_path: str,
    chunk_size: int = 65536
) -> None
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `private_key` | `bytes` | - | Recipient's private key |
| `input_path` | `str` | - | Path to encrypted file |
| `output_path` | `str` | - | Path for decrypted output |
| `chunk_size` | `int` | `65536` | Streaming chunk size (bytes) |

**Raises:**

- `ValueError` — Corrupted header, truncated file, wrong algorithm
- `cryptography.exceptions.InvalidTag` — File was modified

**Example:**

```python
from qcrypto import decrypt_file, KyberKEM

priv = KyberKEM.load_private_key("my.key")
decrypt_file(priv, "large_video.mp4.enc", "large_video.mp4")
```

---

## encrypt_message_armored

Encrypt data and return ASCII-armored string.

```python
from qcrypto import encrypt_message_armored

def encrypt_message_armored(public_key: bytes, plaintext: bytes) -> str
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `public_key` | `bytes` | Recipient's public key |
| `plaintext` | `bytes` | Data to encrypt |

**Returns:** ASCII-armored ciphertext string.

**Example:**

```python
from qcrypto import encrypt_message_armored

armored = encrypt_message_armored(pub, b"Secret message")
print(armored)
# -----BEGIN QCRYPTO MESSAGE-----
# AgEEQJg/+TQjIxlLvaPaBU5VKaXS...
# -----END QCRYPTO MESSAGE-----
```

---

## decrypt_message_armored

Decrypt an ASCII-armored message.

```python
from qcrypto import decrypt_message_armored

def decrypt_message_armored(private_key: bytes, armored: str) -> bytes
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `private_key` | `bytes` | Recipient's private key |
| `armored` | `str` | ASCII-armored ciphertext |

**Returns:** Original plaintext bytes.

**Example:**

```python
from qcrypto import decrypt_message_armored

plaintext = decrypt_message_armored(priv, armored_message)
```

---

## Legacy API

These functions are retained for backwards compatibility with v0.1.x.

### encrypt_for_recipient

```python
from qcrypto import encrypt_for_recipient

def encrypt_for_recipient(
    recipient_public_key: bytes,
    plaintext: bytes
) -> Tuple[bytes, bytes]
```

**Returns:** Tuple of `(kem_ciphertext, aes_blob)` where `aes_blob = nonce + ciphertext + tag`.

!!! warning "Deprecated"
    Use `encrypt()` instead for new code.

---

### decrypt_from_sender

```python
from qcrypto import decrypt_from_sender

def decrypt_from_sender(
    recipient_keys: KyberKeypair,
    kem_ciphertext: bytes,
    aes_blob: bytes
) -> bytes
```

!!! warning "Deprecated"
    Use `decrypt()` instead for new code.

---

## Ciphertext Format

The binary ciphertext format (v2):

```
Offset  Size    Field
------  ------  --------------------------------
0       1       Version (2)
1       1       Algorithm ID (1 = Kyber768)
2       2       Kyber ciphertext length (big-endian)
4       4       CRC32 checksum of bytes 0-3
8       N       Kyber ciphertext (N = length from header)
8+N     12      AES-GCM nonce
20+N    M       AES-GCM ciphertext
20+N+M  16      AES-GCM authentication tag
```

**Total overhead:** 8 + 1088 + 12 + 16 = 1,124 bytes for Kyber768.

---

## Error Handling

```python
from qcrypto import decrypt

try:
    plaintext = decrypt(priv, ciphertext)
except ValueError as e:
    if "Corrupted header" in str(e):
        print("Header checksum mismatch")
    elif "Unsupported" in str(e):
        print("Unknown version or algorithm")
    elif "truncated" in str(e):
        print("File was cut short")
except Exception as e:
    if "InvalidTag" in type(e).__name__:
        print("Decryption failed - wrong key or corrupted data")
```

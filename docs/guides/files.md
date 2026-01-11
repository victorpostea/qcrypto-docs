# File Encryption Guide

qcrypto provides streaming file encryption that handles files of any size without loading them entirely into memory.

## Basic File Encryption

### Encrypt a File

```python
from qcrypto import KyberKEM, encrypt_file

# Load or generate keys
kem = KyberKEM("Kyber768")
keys = kem.generate_keypair()

# Encrypt
encrypt_file(
    public_key=keys.public_key,
    input_path="secret_document.pdf",
    output_path="secret_document.pdf.enc"
)
```

### Decrypt a File

```python
from qcrypto import decrypt_file

decrypt_file(
    private_key=keys.private_key,
    input_path="secret_document.pdf.enc",
    output_path="secret_document.pdf"
)
```

## Using the CLI

```bash
# Generate keys (one-time)
qcrypto gen-key --armored --pass

# Encrypt a file
qcrypto encrypt --in report.xlsx --out report.xlsx.enc

# Decrypt a file
qcrypto decrypt --pass --in report.xlsx.enc --out report.xlsx
```

## Streaming Architecture

qcrypto processes files in 64 KiB chunks by default:

```
┌─────────────────────────────────────────────────────────────┐
│                    File Encryption                           │
├─────────────────────────────────────────────────────────────┤
│  1. Generate Kyber ciphertext + shared secret               │
│  2. Derive AES key via HKDF                                 │
│  3. Write header + Kyber CT + nonce                         │
│  4. Stream file through AES-GCM encryptor                   │
│  5. Append GCM tag                                          │
└─────────────────────────────────────────────────────────────┘
```

This means:

- ✅ 10 GB files work fine
- ✅ Memory usage stays constant (~64 KiB)
- ✅ Compatible with in-memory `encrypt()`/`decrypt()`

## Custom Chunk Size

For very large files or memory-constrained systems:

```python
encrypt_file(
    public_key=pub,
    input_path="huge_backup.tar",
    output_path="huge_backup.tar.enc",
    chunk_size=16 * 1024  # 16 KiB chunks
)
```

## Error Handling

```python
from qcrypto import encrypt_file, decrypt_file

try:
    decrypt_file(priv, "corrupted.enc", "output.txt")
except ValueError as e:
    if "Corrupted header" in str(e):
        print("File header is damaged")
    elif "truncated" in str(e):
        print("File was cut off")
    elif "tag" in str(e).lower():
        print("File was modified (authentication failed)")
```

## File Format

Encrypted files use the same format as `encrypt()`:

```
[8 bytes]    Header (version, algo, length, checksum)
[1088 bytes] Kyber768 ciphertext
[12 bytes]   AES-GCM nonce
[variable]   AES-GCM ciphertext (same size as plaintext)
[16 bytes]   AES-GCM authentication tag
```

**Overhead:** ~1,124 bytes regardless of file size.

## Best Practices

### Batch Encryption

```python
from pathlib import Path
from qcrypto import encrypt_file, KyberKEM

pub = KyberKEM.load_public_key("backup.pub")

for file in Path("sensitive/").glob("*.docx"):
    encrypt_file(pub, str(file), f"{file}.enc")
    file.unlink()  # Remove original after encryption
```

### Secure Deletion

After encrypting, consider secure deletion of originals:

```bash
# macOS/Linux
srm original.pdf  # or: shred -u original.pdf

# Or just encrypt in-place workflow
qcrypto encrypt --in data.db --out data.db.enc && rm data.db
```

### Verify Before Deleting

```python
from qcrypto import encrypt_file, decrypt_file
import tempfile
import filecmp

# Encrypt
encrypt_file(pub, "important.xlsx", "important.xlsx.enc")

# Verify by decrypting to temp
with tempfile.NamedTemporaryFile() as tmp:
    decrypt_file(priv, "important.xlsx.enc", tmp.name)
    if filecmp.cmp("important.xlsx", tmp.name):
        print("Verified! Safe to delete original.")
```

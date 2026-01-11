# ASCII Armor Guide

ASCII armor encodes binary data as text, making keys and messages safe for email, chat, or copy/paste.

## What is ASCII Armor?

```
-----BEGIN QCRYPTO PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3Tz2mr7SZiA
Jkz7PfDkC7YZ43ij7xRwOxMJsOk9v7w3p4z5l6P8xO2R3y4T1xJ0A7n
... (base64 encoded content) ...
XyZ123AbCdEfGhIjKlMnOpQrStUvWxYz==
-----END QCRYPTO PUBLIC KEY-----
```

**Benefits:**

- ✅ Human-readable boundaries
- ✅ Safe for email (no binary corruption)
- ✅ Copy/paste friendly
- ✅ Self-identifying (the label tells you what it is)

## Supported Types

| Label | Content |
|-------|---------|
| `QCRYPTO PUBLIC KEY` | KEM public key |
| `QCRYPTO PRIVATE KEY` | Unencrypted KEM private key |
| `QCRYPTO ENCRYPTED PRIVATE KEY` | Passphrase-protected KEM private key |
| `QCRYPTO SIG PUBLIC KEY` | Signature public key |
| `QCRYPTO SIG PRIVATE KEY` | Signature private key |
| `QCRYPTO SIG ENCRYPTED PRIVATE KEY` | Protected signature private key |
| `QCRYPTO SIGNATURE` | Detached signature |
| `QCRYPTO MESSAGE` | Encrypted message |

## Creating Armored Keys

### CLI

```bash
# Armored encryption keys
qcrypto gen-key --armored

# Armored signature keys
qcrypto sig-gen-key --alg Dilithium3 --armored
```

### Python

```python
from qcrypto import KyberKEM

kem = KyberKEM("Kyber768")
keys = kem.generate_keypair()

# Save armored
kem.save_public_key("my.pub", encoding="armor")
kem.save_private_key("my.key", encoding="armor")
```

## Creating Armored Messages

```python
from qcrypto import encrypt_message_armored, decrypt_message_armored

# Encrypt to armored string
armored = encrypt_message_armored(public_key, b"Secret message")

# The result is a string you can email:
# -----BEGIN QCRYPTO MESSAGE-----
# AgEEQJg/+TQjIxlLvaPaBU5VKaXS...
# -----END QCRYPTO MESSAGE-----

# Decrypt armored message
plaintext = decrypt_message_armored(private_key, armored)
```

## Creating Armored Signatures

### CLI

```bash
qcrypto sign --in document.pdf --out document.sig --armored
```

### Python

```python
from qcrypto import save_signature, load_signature

# Save armored
save_signature("document.sig", signature_bytes, "Dilithium3", armored=True)

# Load (auto-detects armor)
alg, sig = load_signature("document.sig")
```

## Loading Armored Files

qcrypto **auto-detects** armored format when loading:

```python
from qcrypto import KyberKEM

# Works for both armored and raw keys
pub = KyberKEM.load_public_key("key.pub")  # auto-detects format
```

## Low-Level Armor API

For custom use cases:

```python
from qcrypto.armor import armor_encode, armor_decode, looks_armored

# Encode arbitrary data
data = b"some binary data"
armored = armor_encode("MY CUSTOM DATA", data)
# -----BEGIN MY CUSTOM DATA-----
# c29tZSBiaW5hcnkgZGF0YQ==
# -----END MY CUSTOM DATA-----

# Decode
label, decoded = armor_decode(armored)
assert label == "MY CUSTOM DATA"
assert decoded == data

# Check if something is armored
if looks_armored(file_contents):
    label, data = armor_decode(file_contents)
```

## Use Cases

### Sharing Public Keys

```bash
# Export your public key
cat ~/.qcrypto/kem/public.key

# Someone can copy this into a file and use it
```

### Email Encryption

```python
# Sender
message = f"""
Hi Alice,

Here's the encrypted document:

{encrypt_message_armored(alice_pub, document)}

Best,
Bob
"""
send_email(message)

# Recipient
armored = extract_armored_block(email_body)
document = decrypt_message_armored(my_priv, armored)
```

### Key Backup

Armored keys are safe to print or store in password managers:

```bash
# Backup to password manager (armored is text-safe)
qcrypto gen-key --armored --pass
cat ~/.qcrypto/kem/private.key | pbcopy  # copy to clipboard (macOS)
```

## Format Details

The armor format:

1. `-----BEGIN {LABEL}-----` header
2. Base64-encoded payload, wrapped at 64 characters
3. `-----END {LABEL}-----` footer

Labels must:

- Use uppercase letters, numbers, and spaces only
- Match between BEGIN and END lines

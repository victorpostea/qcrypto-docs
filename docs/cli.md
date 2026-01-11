# CLI Reference

qcrypto provides a complete command-line interface for post-quantum cryptography operations.

## Commands Overview

| Command | Description |
|---------|-------------|
| `gen-key` | Generate Kyber encryption keypair |
| `sig-gen-key` | Generate signature keypair (Dilithium/Falcon/SPHINCS+) |
| `encrypt` | Encrypt a file |
| `decrypt` | Decrypt a file |
| `sign` | Sign a file |
| `verify` | Verify a signature |

## Default Key Paths

qcrypto automatically uses these paths when `--key`/`--pub` are not specified:

| Key Type | Path |
|----------|------|
| Encryption private key | `~/.qcrypto/kem/private.key` |
| Encryption public key | `~/.qcrypto/kem/public.key` |
| Signature private key | `~/.qcrypto/sig/private.key` |
| Signature public key | `~/.qcrypto/sig/public.key` |

---

## gen-key

Generate a Kyber keypair for hybrid encryption.

```bash
qcrypto gen-key [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--alg` | Algorithm (default: `kyber768`) |
| `--public PATH` | Output path for public key |
| `--private PATH` | Output path for private key |
| `--armored` | Save in ASCII-armored format |
| `--pass [PASSPHRASE]` | Encrypt private key with passphrase |
| `--force` | Overwrite existing keys |

### Examples

```bash
# Generate with defaults (saves to ~/.qcrypto/kem/)
qcrypto gen-key

# Generate armored keys with passphrase protection
qcrypto gen-key --armored --pass

# Generate to custom paths
qcrypto gen-key --public alice.pub --private alice.key

# Overwrite existing keys
qcrypto gen-key --force
```

---

## sig-gen-key

Generate a signature keypair.

```bash
qcrypto sig-gen-key [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--alg` | Algorithm (default: `Dilithium3`) |
| `--public PATH` | Output path for public key |
| `--private PATH` | Output path for private key |
| `--armored` | Save in ASCII-armored format |
| `--pass [PASSPHRASE]` | Encrypt private key with passphrase |
| `--force` | Overwrite existing keys |

### Supported Algorithms

- `Dilithium2`, `Dilithium3`, `Dilithium5`
- `Falcon-512`, `Falcon-1024`
- `SPHINCS+-SHA2-128f-simple`, `SPHINCS+-SHA2-128s-simple`, etc.

### Examples

```bash
# Generate Dilithium3 keypair (default)
qcrypto sig-gen-key

# Generate Falcon-512 keypair
qcrypto sig-gen-key --alg Falcon-512 --armored

# Generate SPHINCS+ keypair with passphrase
qcrypto sig-gen-key --alg "SPHINCS+-SHA2-128f-simple" --pass
```

---

## encrypt

Encrypt a file using hybrid PQC + AES-GCM.

```bash
qcrypto encrypt --in INPUT --out OUTPUT [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--pub PATH` | Path to public key (default: `~/.qcrypto/kem/public.key`) |
| `--in PATH` | Input file to encrypt (required) |
| `--out PATH` | Output encrypted file (required) |

### Examples

```bash
# Encrypt using default key
qcrypto encrypt --in document.pdf --out document.pdf.enc

# Encrypt with specific public key
qcrypto encrypt --pub recipient.pub --in secret.txt --out secret.enc
```

---

## decrypt

Decrypt a file encrypted with `qcrypto encrypt`.

```bash
qcrypto decrypt --in INPUT --out OUTPUT [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--key PATH` | Path to private key (default: `~/.qcrypto/kem/private.key`) |
| `--in PATH` | Input encrypted file (required) |
| `--out PATH` | Output decrypted file (required) |
| `--pass [PASSPHRASE]` | Passphrase for encrypted private key |

### Examples

```bash
# Decrypt using default key
qcrypto decrypt --in document.pdf.enc --out document.pdf

# Decrypt with passphrase-protected key
qcrypto decrypt --pass --in secret.enc --out secret.txt

# Decrypt with specific key
qcrypto decrypt --key my.key --in message.enc --out message.txt
```

---

## sign

Sign a file with a signature key.

```bash
qcrypto sign --in INPUT --out OUTPUT [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--key PATH` | Path to signature private key (default: `~/.qcrypto/sig/private.key`) |
| `--in PATH` | Input file to sign (required) |
| `--out PATH` | Output signature file (required) |
| `--alg` | Algorithm (only needed for raw keys) |
| `--armored` | Write signature in ASCII-armored format |
| `--pass [PASSPHRASE]` | Passphrase for encrypted private key |

### Examples

```bash
# Sign using default key
qcrypto sign --in contract.pdf --out contract.sig

# Sign with armored output
qcrypto sign --in message.txt --out message.sig --armored

# Sign with passphrase-protected key
qcrypto sign --pass --in document.pdf --out document.sig
```

---

## verify

Verify a signature.

```bash
qcrypto verify --in INPUT --sig SIGNATURE [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--pub PATH` | Path to signature public key (default: `~/.qcrypto/sig/public.key`) |
| `--in PATH` | Input file that was signed (required) |
| `--sig PATH` | Signature file (required) |
| `--alg` | Algorithm (only needed for raw keys) |

### Exit Codes

- `0` — Signature valid
- `2` — Signature invalid

### Examples

```bash
# Verify using default key
qcrypto verify --in contract.pdf --sig contract.sig

# Verify with specific public key
qcrypto verify --pub signer.pub --in message.txt --sig message.sig
```

---

## Typical Workflows

### Personal Encryption Setup

```bash
# One-time setup
qcrypto gen-key --armored --pass

# Daily use
qcrypto encrypt --in secrets.txt --out secrets.enc
qcrypto decrypt --pass --in secrets.enc --out secrets.txt
```

### Document Signing

```bash
# One-time setup
qcrypto sig-gen-key --alg Dilithium3 --armored --pass

# Sign documents
qcrypto sign --pass --in contract.pdf --out contract.sig

# Recipients verify
qcrypto verify --pub signer.pub --in contract.pdf --sig contract.sig
```

### Sharing Public Keys

Your public keys are safe to share. If armored, they're copy/paste friendly:

```bash
cat ~/.qcrypto/kem/public.key
# -----BEGIN QCRYPTO PUBLIC KEY-----
# (base64 content)
# -----END QCRYPTO PUBLIC KEY-----
```

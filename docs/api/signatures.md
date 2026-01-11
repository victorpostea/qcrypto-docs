# Signatures API Reference

Digital signature classes and utilities for post-quantum authentication.

## SignatureScheme

Generic wrapper for any liboqs signature algorithm.

```python
from qcrypto import SignatureScheme
```

### Constructor

```python
SignatureScheme(alg: str)
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `alg` | `str` | Any liboqs signature algorithm name |

**Example:**

```python
scheme = SignatureScheme("Dilithium3")
scheme = SignatureScheme("Falcon-512")
scheme = SignatureScheme("SPHINCS+-SHA2-128f-simple")
```

---

### generate_keypair

Generate a new signature keypair.

```python
def generate_keypair(self) -> SignatureKeypair
```

**Returns:** `SignatureKeypair` with `public_key` and `secret_key` attributes.

**Example:**

```python
scheme = SignatureScheme("Dilithium3")
keys = scheme.generate_keypair()
```

---

### sign

Sign a message.

```python
def sign(self, secret_key: bytes, message: bytes) -> bytes
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `secret_key` | `bytes` | Signing private key |
| `message` | `bytes` | Message to sign |

**Returns:** Signature bytes.

**Example:**

```python
signature = scheme.sign(keys.secret_key, b"Important document")
```

---

### verify

Verify a signature.

```python
def verify(self, public_key: bytes, message: bytes, signature: bytes) -> bool
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `public_key` | `bytes` | Signer's public key |
| `message` | `bytes` | Original message |
| `signature` | `bytes` | Signature to verify |

**Returns:** `True` if valid, `False` otherwise.

**Example:**

```python
valid = scheme.verify(keys.public_key, b"Important document", signature)
if valid:
    print("Signature is authentic")
```

---

## DilithiumSig

Convenience wrapper for Dilithium signatures.

```python
from qcrypto import DilithiumSig

sig = DilithiumSig("Dilithium3")  # or Dilithium2, Dilithium5
```

Same API as `SignatureScheme`.

---

## FalconSig

Convenience wrapper for Falcon signatures.

```python
from qcrypto import FalconSig

sig = FalconSig("Falcon-512")  # or Falcon-1024
```

Same API as `SignatureScheme`.

---

## SphincsSig

Convenience wrapper for SPHINCS+ signatures.

```python
from qcrypto import SphincsSig

sig = SphincsSig("SPHINCS+-SHA2-128f-simple")
```

Same API as `SignatureScheme`.

---

## SignatureKeypair

Dataclass holding a signature keypair.

```python
@dataclass
class SignatureKeypair:
    public_key: bytes
    secret_key: bytes
```

---

## File I/O Functions

### save_signature_public_key

Save a signature public key to a file.

```python
from qcrypto import save_signature_public_key

def save_signature_public_key(
    path: str,
    public_key: bytes,
    alg: str,
    armored: bool = False
) -> None
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `path` | `str` | - | Output file path |
| `public_key` | `bytes` | - | Public key bytes |
| `alg` | `str` | - | Algorithm name |
| `armored` | `bool` | `False` | Use ASCII armor |

---

### load_signature_public_key

Load a signature public key from a file.

```python
from qcrypto import load_signature_public_key

def load_signature_public_key(path: str) -> Tuple[str, bytes]
```

**Returns:** Tuple of `(algorithm_name, public_key_bytes)`.

---

### save_signature_private_key

Save a signature private key to a file.

```python
from qcrypto import save_signature_private_key

def save_signature_private_key(
    path: str,
    secret_key: bytes,
    alg: str,
    armored: bool = False,
    passphrase: Optional[str] = None
) -> None
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `path` | `str` | - | Output file path |
| `secret_key` | `bytes` | - | Secret key bytes |
| `alg` | `str` | - | Algorithm name |
| `armored` | `bool` | `False` | Use ASCII armor |
| `passphrase` | `str` | `None` | Passphrase for encryption |

---

### load_signature_private_key

Load a signature private key from a file.

```python
from qcrypto import load_signature_private_key

def load_signature_private_key(
    path: str,
    passphrase: Optional[str] = None
) -> Tuple[str, bytes]
```

**Returns:** Tuple of `(algorithm_name, secret_key_bytes)`.

---

### save_signature

Save a detached signature to a file.

```python
from qcrypto import save_signature

def save_signature(
    path: str,
    signature: bytes,
    alg: str,
    armored: bool = False
) -> None
```

---

### load_signature

Load a detached signature from a file.

```python
from qcrypto import load_signature

def load_signature(path: str) -> Tuple[str, bytes]
```

**Returns:** Tuple of `(algorithm_name, signature_bytes)`.

---

## Complete Example

```python
from qcrypto import (
    SignatureScheme,
    save_signature_public_key,
    save_signature_private_key,
    load_signature_public_key,
    load_signature_private_key,
    save_signature,
    load_signature,
    key_fingerprint,
)

# Generate keys
scheme = SignatureScheme("Dilithium3")
keys = scheme.generate_keypair()

print(f"Fingerprint: {key_fingerprint(keys.public_key)}")

# Save keys
save_signature_public_key("signer.pub", keys.public_key, "Dilithium3", armored=True)
save_signature_private_key("signer.key", keys.secret_key, "Dilithium3", 
                           armored=True, passphrase="secret")

# Sign a document
document = open("contract.pdf", "rb").read()
signature = scheme.sign(keys.secret_key, document)
save_signature("contract.sig", signature, "Dilithium3", armored=True)

# Later: verify
alg, pub = load_signature_public_key("signer.pub")
_, sig = load_signature("contract.sig")
scheme2 = SignatureScheme(alg)

valid = scheme2.verify(pub, document, sig)
print(f"Valid: {valid}")
```

# KEM API Reference

Key Encapsulation Mechanism (KEM) classes for post-quantum key exchange.

## KyberKEM

The primary KEM class using the Kyber algorithm.

```python
from qcrypto import KyberKEM
```

### Constructor

```python
KyberKEM(alg: str = "Kyber768")
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `alg` | `str` | `"Kyber768"` | Kyber variant: `Kyber512`, `Kyber768`, or `Kyber1024` |

**Example:**

```python
kem = KyberKEM("Kyber768")
```

---

### generate_keypair

Generate a new Kyber keypair.

```python
def generate_keypair(self) -> KyberKeypair
```

**Returns:** `KyberKeypair` with `public_key` and `private_key` attributes.

**Example:**

```python
kem = KyberKEM("Kyber768")
keys = kem.generate_keypair()
print(len(keys.public_key))   # 1184
print(len(keys.private_key))  # 2400
```

---

### encapsulate

Encapsulate a shared secret using a public key.

```python
def encapsulate(self, public_key: bytes) -> Tuple[bytes, bytes]
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `public_key` | `bytes` | Recipient's public key |

**Returns:** Tuple of `(ciphertext, shared_secret)`

**Example:**

```python
ciphertext, shared_secret = kem.encapsulate(recipient_public_key)
# Send ciphertext to recipient
# Use shared_secret to derive encryption keys
```

---

### decapsulate

Recover the shared secret from a ciphertext.

```python
def decapsulate(self, ciphertext: bytes, private_key: bytes = None) -> bytes
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `ciphertext` | `bytes` | KEM ciphertext from encapsulate |
| `private_key` | `bytes` | Private key (optional if keypair was generated with this instance) |

**Returns:** The shared secret bytes.

**Example:**

```python
shared_secret = kem.decapsulate(ciphertext, private_key=my_private_key)
```

---

### save_public_key

Save the public key to a file.

```python
def save_public_key(self, path: str = "public.key", encoding: str = "raw")
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `path` | `str` | `"public.key"` | Output file path |
| `encoding` | `str` | `"raw"` | `"raw"`, `"base64"`, or `"armor"` |

**Example:**

```python
kem.save_public_key("my.pub", encoding="armor")
```

---

### save_private_key

Save the private key to a file, optionally with passphrase protection.

```python
def save_private_key(
    self,
    path: str = "private.key",
    encoding: str = "raw",
    passphrase: Optional[str] = None
)
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `path` | `str` | `"private.key"` | Output file path |
| `encoding` | `str` | `"raw"` | `"raw"`, `"base64"`, or `"armor"` |
| `passphrase` | `str` | `None` | Passphrase for encryption |

**Example:**

```python
kem.save_private_key("my.key", encoding="armor", passphrase="secret")
```

---

### load_public_key (static)

Load a public key from a file.

```python
@staticmethod
def load_public_key(path: str = "public.key", encoding: str = "raw") -> bytes
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `path` | `str` | `"public.key"` | Input file path |
| `encoding` | `str` | `"raw"` | `"raw"` or `"base64"` (armor auto-detected) |

**Returns:** Public key bytes.

**Example:**

```python
pub = KyberKEM.load_public_key("recipient.pub")
```

---

### load_private_key (static)

Load a private key from a file.

```python
@staticmethod
def load_private_key(
    path: str = "private.key",
    encoding: str = "raw",
    passphrase: Optional[str] = None
) -> bytes
```

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `path` | `str` | `"private.key"` | Input file path |
| `encoding` | `str` | `"raw"` | `"raw"` or `"base64"` (armor auto-detected) |
| `passphrase` | `str` | `None` | Passphrase if key is encrypted |

**Returns:** Private key bytes.

**Example:**

```python
priv = KyberKEM.load_private_key("my.key", passphrase="secret")
```

---

## KyberKeypair

Dataclass holding a Kyber keypair.

```python
@dataclass
class KyberKeypair:
    public_key: bytes
    private_key: bytes
```

### fingerprint

Get the key fingerprint.

```python
def fingerprint(self) -> str
```

**Returns:** 32-character hex string (SHA256 of public key, first 16 bytes).

**Example:**

```python
keys = kem.generate_keypair()
print(keys.fingerprint())  # "a1b2c3d4e5f67890..."
```

---

## ClassicMcElieceKEM

KEM using the Classic McEliece algorithm. Same API as `KyberKEM`.

```python
from qcrypto import ClassicMcElieceKEM

kem = ClassicMcElieceKEM("Classic-McEliece-348864")
keys = kem.generate_keypair()

# Note: Classic McEliece has very large keys
print(len(keys.public_key))   # ~261,120 bytes!
print(len(keys.private_key))  # ~6,492 bytes
```

**Supported variants:**

- `Classic-McEliece-348864` (default)
- `Classic-McEliece-348864f`
- `Classic-McEliece-460896`
- `Classic-McEliece-460896f`
- `Classic-McEliece-6688128`
- `Classic-McEliece-6688128f`
- `Classic-McEliece-6960119`
- `Classic-McEliece-6960119f`
- `Classic-McEliece-8192128`
- `Classic-McEliece-8192128f`

---

## key_fingerprint

Standalone function to compute key fingerprints.

```python
from qcrypto import key_fingerprint

def key_fingerprint(public_key: bytes) -> str
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `public_key` | `bytes` | Any public key bytes |

**Returns:** 32-character hex string.

**Example:**

```python
fp = key_fingerprint(some_public_key)
print(f"Key fingerprint: {fp}")
```

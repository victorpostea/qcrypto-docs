# Quickstart

Get started with qcrypto in 5 minutes.

## Install

```bash
pip install qcrypto
```

## Generate Your First Keypair

=== "CLI"

    ```bash
    qcrypto gen-key
    ```
    
    Output:
    ```
    Generated Kyber768 keypair:
      Public key:  /home/user/.qcrypto/kem/public.key
      Fingerprint: a1b2c3d4e5f67890...
      Private key: /home/user/.qcrypto/kem/private.key
    ```

=== "Python"

    ```python
    from qcrypto import KyberKEM, key_fingerprint

    kem = KyberKEM("Kyber768")
    keys = kem.generate_keypair()

    print(f"Fingerprint: {key_fingerprint(keys.public_key)}")
    ```

## Encrypt a Message

=== "CLI"

    ```bash
    # Create a test file
    echo "Secret message" > message.txt
    
    # Encrypt it
    qcrypto encrypt --in message.txt --out message.enc
    ```

=== "Python"

    ```python
    from qcrypto import KyberKEM, encrypt

    # Load the public key
    pub = KyberKEM.load_public_key("~/.qcrypto/kem/public.key")

    # Encrypt
    plaintext = b"Secret message"
    ciphertext = encrypt(pub, plaintext)

    print(f"Ciphertext size: {len(ciphertext)} bytes")
    ```

## Decrypt the Message

=== "CLI"

    ```bash
    qcrypto decrypt --in message.enc --out message.dec.txt
    cat message.dec.txt
    # Secret message
    ```

=== "Python"

    ```python
    from qcrypto import KyberKEM, decrypt

    # Load the private key
    priv = KyberKEM.load_private_key("~/.qcrypto/kem/private.key")

    # Decrypt
    plaintext = decrypt(priv, ciphertext)
    print(plaintext.decode())  # "Secret message"
    ```

## Sign a Document

=== "CLI"

    ```bash
    # Generate signature keys
    qcrypto sig-gen-key --alg Dilithium3
    
    # Sign
    qcrypto sign --in document.pdf --out document.sig
    
    # Verify
    qcrypto verify --in document.pdf --sig document.sig
    # OK: signature valid
    ```

=== "Python"

    ```python
    from qcrypto import SignatureScheme

    # Create scheme and keys
    scheme = SignatureScheme("Dilithium3")
    keys = scheme.generate_keypair()

    # Sign
    document = open("document.pdf", "rb").read()
    signature = scheme.sign(keys.secret_key, document)

    # Verify
    valid = scheme.verify(keys.public_key, document, signature)
    print(f"Valid: {valid}")  # True
    ```

## Protect Keys with a Passphrase

```bash
# Generate passphrase-protected keys
qcrypto gen-key --pass

# The CLI prompts for passphrase
# Passphrase: ********

# Decrypt requires the passphrase
qcrypto decrypt --pass --in secret.enc --out secret.txt
```

## Use ASCII-Armored Keys

Armored keys are human-readable and safe for copy/paste:

```bash
qcrypto gen-key --armored
cat ~/.qcrypto/kem/public.key
```

Output:
```
-----BEGIN QCRYPTO PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
(base64 content)
-----END QCRYPTO PUBLIC KEY-----
```

## Next Steps

- [Hybrid Encryption Guide](encryption.md) — Deep dive into encryption
- [Digital Signatures Guide](signatures.md) — Learn about signing
- [CLI Reference](../cli.md) — All CLI commands
- [API Reference](../api/kem.md) — Python API docs

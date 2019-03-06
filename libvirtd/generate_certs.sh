#! /usr/bin/env bash

mkdir -p certs

# generate private key for CA
(umask 277 && certtool --generate-privkey > certs/ca_key.pem)

# generate CA cert
certtool --generate-self-signed \
            --template ca_template.info \
            --load-privkey certs/ca_key.pem \
            --outfile certs/ca_cert.pem

# generate server key
(umask 277 && certtool --generate-privkey > certs/server_key.pem)

# sign with ca
certtool --generate-certificate \
            --template server_template.info \
            --load-privkey certs/server_key.pem \
            --load-ca-certificate certs/ca_cert.pem \
            --load-ca-privkey certs/ca_key.pem \
            --outfile certs/server_cert.pem

# generate client key
(umask 277 && certtool --generate-privkey > certs/client_key.pem)

# sign with ca
certtool --generate-certificate \
            --template client_template.info \
            --load-privkey certs/client_key.pem \
            --load-ca-certificate certs/ca_cert.pem \
            --load-ca-privkey certs/ca_key.pem \
            --outfile certs/client_cert.pem


#! /usr/bin/env bash

mkdir -p certs

# generate private key for CA
(umask 277 && certtool --generate-privkey > certs/cakey.pem)

# generate CA cert
certtool --generate-self-signed \
            --template ca_template.info \
            --load-privkey certs/cakey.pem \
            --outfile certs/cacert.pem

# generate server key
(umask 277 && certtool --generate-privkey > certs/serverkey.pem)

# sign with ca
certtool --generate-certificate \
            --template server_template.info \
            --load-privkey certs/serverkey.pem \
            --load-ca-certificate certs/cacert.pem \
            --load-ca-privkey certs/cakey.pem \
            --outfile certs/servercert.pem

# generate client key
(umask 277 && certtool --generate-privkey > certs/clientkey.pem)

# sign with ca
certtool --generate-certificate \
            --template client_template.info \
            --load-privkey certs/clientkey.pem \
            --load-ca-certificate certs/cacert.pem \
            --load-ca-privkey certs/cakey.pem \
            --outfile certs/clientcert.pem


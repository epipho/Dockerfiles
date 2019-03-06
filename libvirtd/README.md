# libvirt

Simple libvirtd setup with a TLS listener. Designed to test and validate certs and connectivity, actual libvirt functionality is limited.

## Quickstart

Generate CA, server and client keys and certs
`./generate_certs.sh`

Start service
`docker-compose up`

Use the built virsh docker container
`./virsh <command>`

Use virsh from the local machine.

`virsh -c "qemu://localhost/system?pkipath=certs&no_verify=1"`

no_verify must be on as localhost does not match the server cert's host. This can be fixed by adding "libvirt 127.0.0.1" to your hosts file and using
`virsh -c "qemuL//libvirt/system?pkipath=certs"`


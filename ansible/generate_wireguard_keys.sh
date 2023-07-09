#!/bin/bash
private_key_file="privatekey"
public_key_file="publickey"
# Permit to override the default keys path
if [ -n "$1" ]; then
    private_key_file="$1"
fi
if [ -n "$2" ]; then
    public_key_file="$2"
fi
# Check if keys already exist
if [ -f "$private_key_file" ] && [ -f "$public_key_file" ]; then
    echo "Keys already exist"
    exit 0
fi
wg genkey | tee $private_key_file | wg pubkey > $public_key_file

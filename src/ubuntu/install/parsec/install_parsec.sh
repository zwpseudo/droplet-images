#!/usr/bin/env bash
set -ex

# Install Parsec
wget -q https://builds.parsec.app/package/parsec-linux.deb
apt-get update
apt-get install -y ./parsec-linux.deb
rm -f parsec-linux.deb
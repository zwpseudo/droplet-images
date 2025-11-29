#!/usr/bin/env bash
set -ex

ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

if [ "${ARCH}" == "arm64" ] ; then
    echo "Teams for arm64 currently not supported, skipping install"
    exit 0
fi

TMP_DEB="/tmp/teams.deb"
curl -fsSL -o "${TMP_DEB}" "https://go.microsoft.com/fwlink/p/?linkid=2112886&clcid=0x409&culture=en-us&country=us"

apt-get update
pushd /tmp >/dev/null
apt-get install -y ./teams.deb
popd >/dev/null
rm -f "${TMP_DEB}"

sed -i 's/Exec=teams/Exec=teams --no-sandbox/g' /usr/share/applications/teams.desktop || true
cp /usr/share/applications/teams.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/teams.desktop
chown 1000:1000 $HOME/Desktop/teams.desktop

if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi

chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;

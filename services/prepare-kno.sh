#!/bin/bash
set -eu
node=$(basename "$1" .toml)
case "$node" in
    *-authority) role=authority ;;
    *-mixserver) role=mix ;;
    *-gatewaynode) role=gateway ;;
    *-servicenode) role=courier ;;
    *-storagenode*) role=replica ;;
    *) echo "Use a rendered Namenlos node config name" >&2; exit 1 ;;
esac
if [ -z "${KNO_DIR:-}" ]; then
    KNO_DIR="$HOME/.cache/katzenpost-docker/kno"
    [ -d "$KNO_DIR/.git" ] || git clone --depth 1 https://github.com/katzenpost/kno.git "$KNO_DIR"
    git -C "$KNO_DIR" pull --ff-only https://github.com/katzenpost/kno.git main
fi
network="$(cd "$KNO_DIR" && pwd)/data/networks/namenlos/.generated"
config="$network/configs/$node.toml"
test -f "$config"
cd "$(dirname "$0")/$role"
for path in conf data logs data/courier "conf/$role.toml" conf/listen conf/courier-plugin.toml; do test ! -L "$path"; done
mkdir -p conf data logs
chmod -R 700 data
{
    [ "$role" != replica ] || echo 'BindAddresses = ["tcp://0.0.0.0:8181"]'
    sed -e '/^[[:space:]]*BindAddresses[[:space:]]*=/d' \
        -e 's|\[Server\]|[Server]\nBindAddresses = ["tcp://0.0.0.0:8181"]|' \
        -e 's|DataDir = "[^"]*"|DataDir = "/var/lib/katzenpost"|' \
        -e 's|/usr/bin/kpcourier|/usr/bin/courier|g' \
        -e 's|c = "[^"]*courier.toml"|c = "/conf/courier-plugin.toml"|' "$config"
} > "conf/$role.toml"
sed -n 's|^[[:space:]]*Addresses = \["tcp://[^"]*:\([0-9]*\)".*|0.0.0.0:\1|p' "$config" | head -n 1 > conf/listen
if [ "$role" = courier ]; then
    mkdir -p data/courier
    chmod -R 700 data
    cp "$network/configs/courier.toml" conf/courier-plugin.toml
fi
for key in "$network"/keys/*/*_pub_key.pem "$network"/keys/*/*_pub.key.pem "$network"/keys/*/*replica*.public.pem; do
    [ -f "$key" ] || continue
    target="data/${key##*/}"
    test ! -L "$target"
    grep -q 'PUBLIC KEY' "$key"
    if grep -q 'PRIVATE KEY' "$key" "$target" 2>/dev/null; then exit 1; fi
    cp "$key" "$target"
done

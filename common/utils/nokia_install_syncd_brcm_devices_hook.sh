#!/bin/bash
# Patch host /usr/bin/syncd.sh to pass Nokia BDB nodes into syncd at docker create.

set -euo pipefail

MARKER="nokia-brcm-syncd-devices"
SYNCD_CTL="${SYNCD_CTL:-/usr/bin/syncd.sh}"

if [ ! -f "$SYNCD_CTL" ]; then
    echo "$0: skip, $SYNCD_CTL not found"
    exit 0
fi

if grep -q "$MARKER" "$SYNCD_CTL"; then
    exit 0
fi

if ! grep -q 'BRCM_DEV_MNT=""' "$SYNCD_CTL"; then
    echo "$0: skip, $SYNCD_CTL has no BRCM_DEV_MNT block"
    exit 0
fi

tmp=$(mktemp)
# Copy syncd.sh to $tmp, inserting the Nokia hook once immediately after the
# Broadcom BRCM_DEV_MNT for-loop (anchored at "linux-knet-cb; do", first "    done").
awk -v marker="$MARKER" '
    /linux-knet-cb; do/ { in_brcm_loop=1 }
    in_brcm_loop && /^    done$/ && !hooked {
        print
        print "    # " marker
        print "    if [ -x /usr/local/bin/nokia_brcm_syncd_host_devices.sh ]; then"
        print "        BRCM_DEV_MNT=\"$BRCM_DEV_MNT $(/usr/local/bin/nokia_brcm_syncd_host_devices.sh)\""
        print "    fi"
        hooked=1
        next
    }
    { print }
' "$SYNCD_CTL" > "$tmp"
chmod --reference="$SYNCD_CTL" "$tmp"
mv "$tmp" "$SYNCD_CTL"
echo "$0: installed $MARKER hook in $SYNCD_CTL"

#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

VISIONCOIND=${VISIONCOIND:-$SRCDIR/VISIONcoind}
VISIONCOINCLI=${VISIONCOINCLI:-$SRCDIR/VISIONcoin-cli}
VISIONCOINTX=${VISIONCOINTX:-$SRCDIR/VISIONcoin-tx}
VISIONCOINQT=${VISIONCOINQT:-$SRCDIR/qt/VISIONcoin-qt}

[ ! -x $VISIONCOIND ] && echo "$VISIONCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
VSCVER=($($VISIONCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$VISIONCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $VISIONCOIND $VISIONCOINCLI $VISIONCOINTX $VISIONCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${VSCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${VSCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2

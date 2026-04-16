#!/bin/sh

# Compilation script for DADJOKE RPG program
# Runs locally, compiles remotely on IBM i

SERVER="158.176.147.237"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY="${SCRIPT_DIR}/../private_key.pem"
USER="cecuser"
LIBRARY="JOKE"
SRCFILE="QRPGLESRC"
MEMBER="DADJOKE"
MODULE="DADJOKE"
PROGRAM="DADJOKE"
LOCAL_SRC="${SCRIPT_DIR}/../QRPGLESRC/DADJOKE.PGM.RPGLE"

echo "=== Compiling DADJOKE program ==="

# Copy source file to IBM i
echo "Copying source to IBM i..."
scp -i "$KEY" "$LOCAL_SRC" "${USER}@${SERVER}:/tmp/DADJOKE.rpgle"

if [ $? -ne 0 ]; then
    echo "Error: Failed to copy source file"
    exit 1
fi

# Execute compilation commands on IBM i
echo "Executing compilation on IBM i..."
ssh -i "$KEY" "${USER}@${SERVER}" /QOpenSys/usr/bin/sh << 'ENDSSH'

echo "Creating library..."
system "CRTLIB LIB(JOKE) TEXT('Dad Joke Program Library')" || echo "Library exists"

echo "Creating source file..."
system "CRTSRCPF FILE(JOKE/QRPGLESRC) RCDLEN(112) TEXT('RPG Source')" || echo "Source file exists"

echo "Adding member..."
system "ADDPFM FILE(JOKE/QRPGLESRC) MBR(DADJOKE) SRCTYPE(RPGLE) TEXT('Dad Joke Program')" || echo "Member exists"

echo "Clearing member..."
system "CLRPFM FILE(JOKE/QRPGLESRC) MBR(DADJOKE)"

echo "Copying source to member..."
system "CPYFRMSTMF FROMSTMF('/tmp/DADJOKE.rpgle') TOMBR('/QSYS.LIB/JOKE.LIB/QRPGLESRC.FILE/DADJOKE.MBR') MBROPT(*REPLACE)"

echo "Deleting old module..."
system "DLTMOD MODULE(JOKE/DADJOKE)" || echo "No module to delete"

echo "Compiling module..."
system "CRTRPGMOD MODULE(JOKE/DADJOKE) SRCFILE(JOKE/QRPGLESRC) SRCMBR(DADJOKE) DBGVIEW(*SOURCE) INCDIR('/QIBM/ProdData/HTTP' '/QSYS.LIB/LIBHTTP.LIB')"

echo "Deleting old program..."
system "DLTPGM PGM(JOKE/DADJOKE)" || echo "No program to delete"

echo "Creating program..."
system "CRTPGM PGM(JOKE/DADJOKE) MODULE(JOKE/DADJOKE) BNDSRVPGM(LIBHTTP/HTTPAPIR4) ACTGRP(*NEW) TEXT('Dad Joke Program')"

echo "Cleaning up temp file..."
rm -f /tmp/DADJOKE.rpgle

echo "Done"

ENDSSH

if [ $? -eq 0 ]; then
    echo "=== Compilation completed successfully ==="
else
    echo "=== Compilation failed ==="
    exit 1
fi
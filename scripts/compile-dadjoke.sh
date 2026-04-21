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

# Create remote compilation script
cat > /tmp/compile_remote.sh << 'EOFSCRIPT'
#!/usr/bin/bash
echo "=== Starting remote compilation ==="
echo "Creating library..."
system "CRTLIB LIB(JOKE) TEXT('Dad Joke Program Library')" 2>&1 || echo "Library exists or creation failed"

echo "Creating source file..."
system "CRTSRCPF FILE(JOKE/QRPGLESRC) RCDLEN(112) TEXT('RPG Source')" 2>&1 || echo "Source file exists or creation failed"

echo "Adding member..."
system "ADDPFM FILE(JOKE/QRPGLESRC) MBR(DADJOKE) SRCTYPE(RPGLE) TEXT('Dad Joke Program')" 2>&1 || echo "Member exists or creation failed"

echo "Clearing member..."
system "CLRPFM FILE(JOKE/QRPGLESRC) MBR(DADJOKE)" 2>&1 || echo "Clear failed"

echo "Copying source to member..."
system "CPYFRMSTMF FROMSTMF('/tmp/DADJOKE.rpgle') TOMBR('/QSYS.LIB/JOKE.LIB/QRPGLESRC.FILE/DADJOKE.MBR') MBROPT(*REPLACE)" 2>&1 || echo "Copy failed"

echo "Deleting old module..."
system "DLTMOD MODULE(JOKE/DADJOKE)" 2>&1 || echo "Module delete failed or doesn't exist"

echo "Compiling module..."
system "CRTRPGMOD MODULE(JOKE/DADJOKE) SRCFILE(JOKE/QRPGLESRC) SRCMBR(DADJOKE) DBGVIEW(*SOURCE) INCDIR('/QIBM/ProdData/HTTP' '/QSYS.LIB/LIBHTTP.LIB')" 2>&1 | tee /tmp/compile.log
COMPILE_RC=${PIPESTATUS[0]}
if grep -qE "(not created|Compilation failed|severity [3-9]0)" /tmp/compile.log; then
    echo "ERROR: Module compilation failed (RC=$COMPILE_RC)"
    exit 1
fi
echo "Module compiled successfully"

echo "Deleting old program..."
system "DLTPGM PGM(JOKE/DADJOKE)" 2>&1 || echo "Program delete failed or doesn't exist"

echo "Creating program..."
system "CRTPGM PGM(JOKE/DADJOKE) MODULE(JOKE/DADJOKE) BNDSRVPGM(LIBHTTP/HTTPAPIR4) ACTGRP(*NEW) TEXT('Dad Joke Program')" 2>&1 | tee -a /tmp/compile.log
CRTPGM_RC=${PIPESTATUS[0]}
if grep -qE "(not created|Program .* not created)" /tmp/compile.log; then
    echo "ERROR: Program creation failed (RC=$CRTPGM_RC)"
    exit 1
fi
echo "Program created successfully"

echo "Cleaning up temp file..."
rm -f /tmp/DADJOKE.rpgle /tmp/compile.log

echo "=== Remote compilation finished ==="
exit 0
EOFSCRIPT

# Copy script to IBM i and execute
echo "Executing compilation on IBM i..."
scp -i "$KEY" /tmp/compile_remote.sh "${USER}@${SERVER}:/tmp/compile_remote.sh"
ssh -i "$KEY" "${USER}@${SERVER}" "chmod +x /tmp/compile_remote.sh && /tmp/compile_remote.sh"

SSH_EXIT=$?
if [ $SSH_EXIT -eq 0 ]; then
    echo "=== Compilation completed successfully ==="
else
    echo "=== Compilation failed with exit code $SSH_EXIT ==="
    exit 1
fi
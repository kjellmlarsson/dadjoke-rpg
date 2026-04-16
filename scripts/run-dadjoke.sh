#!/bin/sh

# Execution script for DADJOKE RPG program
# Runs locally, executes remotely on IBM i

SERVER="158.176.147.237"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY="${SCRIPT_DIR}/../private_key.pem"
USER="cecuser"
LIBRARY="JOKE"
PROGRAM="DADJOKE"

echo "=== Running DADJOKE program ==="
echo ""

# Create temporary SQL script locally
TEMP_SQL="/tmp/run_dadjoke_$$.sql"
cat > "$TEMP_SQL" << 'EOSQL'
-- Add libraries to library list
CALL QSYS2.QCMDEXC('ADDLIBLE LIB(LIBHTTP)');
CALL QSYS2.QCMDEXC('ADDLIBLE LIB(JOKE)');

-- Call the program
CALL QSYS2.QCMDEXC('CALL PGM(JOKE/DADJOKE)');
EOSQL

# Copy SQL script to IBM i
scp -i "$KEY" "$TEMP_SQL" "${USER}@${SERVER}:/tmp/run_dadjoke.sql" >/dev/null 2>&1

# Execute via RUNSQLSTM (suppress output)
echo "" | ssh -i "$KEY" "${USER}@${SERVER}" "system 'RUNSQLSTM SRCSTMF('\''/tmp/run_dadjoke.sql'\'') COMMIT(*NONE) NAMING(*SQL)'" >/dev/null 2>&1

# Wait for messages
sleep 2

# Get the most recent joke messages
ssh -i "$KEY" "${USER}@${SERVER}" "system 'DSPMSG MSGQ(QSYS/QSYSOPR)'" 2>&1 | \
  grep "DSPLY" | \
  sed 's/.*DSPLY  *//' | \
  tail -5

# Cleanup
rm -f "$TEMP_SQL"
ssh -i "$KEY" "${USER}@${SERVER}" "rm -f /tmp/run_dadjoke.sql" 2>/dev/null

echo ""
echo "=== Execution completed ==="
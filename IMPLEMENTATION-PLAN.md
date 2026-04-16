# Implementation Plan: Dad Joke RPG Program

## Overview
Build an IBM i RPG program that fetches dad jokes from an API and displays them to users, with local development and remote compilation workflow.

## Directory Structure
```
dadjoke-rpg/
├── QRPGLESRC/
│   └── DADJOKE.PGM.RPGLE
├── scripts/
│   ├── compile-dadjoke.sh
│   └── run-dadjoke.sh
└── spec/
    └── DADJOKE-SIMPLE-SPEC.md (exists)
```

## Implementation Steps

### 1. RPG Program (`QRPGLESRC/DADJOKE.PGM.RPGLE`) ✅ COMPLETE
- Include HTTPAPI header: `/copy LIBHTTP/qrpglesrc,httpapi_h`
- Define variables for joke storage (handle >52 char limit)
- Call `http_string()` with:
  - URL: `https://icanhazdadjoke.com/`
  - Content-Type: `text/plain`
  - SSL verification enabled
- Loop through joke text in 51-char chunks (DSPLY has 52-char limit including response character)
- Display each chunk with `DSPLY`
- Wait for user input before exit

### 2. Compilation Script (`scripts/compile-dadjoke.sh`) ✅ COMPLETE
- Use `scp` with `private_key.pem` to copy source to `158.176.147.237`
- SSH commands to:
  - Create `JOKE` library if missing (`CRTLIB`)
  - Create `QRPGLESRC` source file if missing (`CRTSRCPF`)
  - Add member if missing (`ADDPFM`)
  - Compile module with `CRTRPGMOD`:
    - `DBGVIEW(*SOURCE)`
    - `INCDIR('/QIBM/ProdData/...' '/QSYS.LIB/LIBHTTP.LIB/...')`
  - Create program with `CRTPGM`:
    - Bind `LIBHTTP/HTTPAPIR4` service program
- Handle existing objects gracefully

### 3. Execution Script (`scripts/run-dadjoke.sh`) ✅ COMPLETE
- Generate temp SQL file with:
  - `QSYS2.QCMDEXC` to add `LIBHTTP` and `JOKE` to library list
  - Call `JOKE/DADJOKE`
- Upload and execute via `RUNSQLSTM`
- Retrieve output from `QSYSOPR` message queue
- Display on local terminal

## Key Technical Details
- **API endpoint**: `https://icanhazdadjoke.com/` (text/plain)
- **Server**: `158.176.147.237` (SSH key: `private_key.pem`)
- **Library**: `JOKE`
- **Program**: `DADJOKE`
- **Dependencies**: LIBHTTP/HTTPAPIR4 service program
- **Character limit**: 51 chars per `DSPLY` (52 total minus 1 for response character)

## Progress

- ✅ **Step 1**: RPG program created at `QRPGLESRC/DADJOKE.PGM.RPGLE`
- ✅ **Step 2**: Compilation script created and tested at `scripts/compile-dadjoke.sh`
  - Program successfully compiled on IBM i
  - Program object: JOKE/DADJOKE (163840 bytes, RPGLE)
- ✅ **Step 3**: Execution script created at `scripts/run-dadjoke.sh`
  - Adds LIBHTTP and JOKE to library list via SQL
  - Calls DADJOKE program via QSYS2.QCMDEXC
  - Retrieves output from QSYSOPR message queue
  - Ready for testing
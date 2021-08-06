#!/bin/bash
powershell.exe docker compose down
./wsl-build.sh
powershell.exe docker compose up
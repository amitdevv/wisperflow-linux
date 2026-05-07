#!/bin/bash
cd "$(dirname "$0")"

PYTHON_BIN="./venv/bin/python"
if [ ! -x "$PYTHON_BIN" ]; then
  PYTHON_BIN="python3"
fi

exec sg input -c "$PYTHON_BIN linuxflow.py --daemon --model small"

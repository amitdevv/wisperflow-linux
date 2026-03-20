#!/bin/bash
cd "$(dirname "$0")"
exec sg input -c "python wisprflow.py --daemon --model small"

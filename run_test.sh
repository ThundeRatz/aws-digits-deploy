#!/bin/bash
set -e
cd "$(dirname "$0")"
export PYTHONPATH="$(pwd)"

python -m pytest

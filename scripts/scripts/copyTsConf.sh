#!/bin/bash

# Copy preset tsconfig.json to the current folder

SCRIPT_DIR=~/.templates  # folder where your preset tsconfig.json lives
TARGET_DIR=$(pwd)       # current working directory

if [ ! -f "$SCRIPT_DIR/tsconfig.json" ]; then
  echo "Preset tsconfig.json not found in $SCRIPT_DIR"
  exit 1
fi

# Optional: warn if tsconfig already exists
if [ -f "$TARGET_DIR/tsconfig.json" ]; then
  echo "tsconfig.json already exists in this directory. Overwrite? (y/n)"
  read answer
  if [ "$answer" != "y" ]; then
    echo "Aborting."
    exit 0
  fi
fi

cp "$SCRIPT_DIR/tsconfig.json" "$TARGET_DIR/tsconfig.json"
echo "tsconfig.json copied to $TARGET_DIR"

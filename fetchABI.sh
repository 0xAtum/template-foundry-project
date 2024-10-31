#!/bin/bash

# This script extracts the ABI from the compiled JSON files and saves them in the abis directory.
# Your contract must have the @custom:export abi for the script to work.
#
# e.g:
# 
# @custom:export abi
# contract MyContract {
#       ...
#  }
#

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'


BASE_DIR="./out"
OUTPUT_DIR="./abis"
QUERY_DEV_DOC='.rawMetadata | fromjson | .output.devdoc."custom:export" == "abi"'


mkdir -p "$OUTPUT_DIR"
rm -rf "$OUTPUT_DIR"/*

forge build

find "$BASE_DIR" -type f -name "*.json" | while read -r json_file; do
    if jq -e "$QUERY_DEV_DOC" "$json_file" > /dev/null 2>&1; then
        abi=$(jq -r '.abi' "$json_file")

        if [[ "$abi" != "null" && -n "$abi" ]]; then
            output_file="$OUTPUT_DIR/$(basename "$json_file" .json).json"
            echo "$abi" > "$output_file"
        else
            echo -e "${YELLOW}No ABI found in $json_file.${NC}"
        fi
    else
        echo -e "${YELLOW}No 'custom:export abi' found in $json_file.${NC}"
    fi
done

echo -e "${GREEN}\nABI files in the output directory:${NC}"
for abi_file in "$OUTPUT_DIR"/*.json; do
    if [[ -e $abi_file ]]; then
        echo -e "  ${GREEN}Extracted ABI from $(basename "$abi_file")${NC}"
    fi
done

read -p "Do you want to zip the '$OUTPUT_DIR' directory? (Y/n): " zip_choice
zip_choice=${zip_choice:-y} 

if [[ "$zip_choice" == "y" || "$zip_choice" == "Y" ]]; then
    zip_file_name="${OUTPUT_DIR}/abis.zip"
    zip -r "$zip_file_name" "$OUTPUT_DIR"
    echo "Zipped '$OUTPUT_DIR' into '$zip_file_name'."
else
    echo "Skipping zip."
fi

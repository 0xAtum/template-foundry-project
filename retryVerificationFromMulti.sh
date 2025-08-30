#!/bin/bash

#
# Note: This script is in beta and may not work as expected.
# Known issue: The latest-run CREATE transaction may lack constructor arguments even if it's present in the deployment file.
# Improvement suggestion: Extract constructor data from Transactions.transaction.input, that will cut 70% of the file size and fix the issues.
#

echo "Available subfolders in ./broadcast:"
select folder in ./broadcast/*; do
  if [ -n "$folder" ]; then
    echo "You have selected the folder: $folder"
    break
  fi
  echo "Invalid selection. Please try again."
done

while true; do
  echo "Please enter the subfolder you want to use in '$folder':"
  select subfolder in "$folder"/*; do
    if [ -n "$subfolder" ]; then
      echo "You have selected the subfolder: $subfolder"
      folder="$subfolder"
      break 2
    fi
    echo "Invalid selection. Please try again."
  done
done

run_latest_file="$folder/run.json"

if [ ! -f "$run_latest_file" ]; then
  echo "'run-latest.json' not found in '$folder'."
  exit 1
fi


deployments=$(jq -c '.deployments[]' "$run_latest_file")
echo "$deployments" | while IFS= read -r deployment; do
  transactions=$(echo "$deployment" | jq -c '.transactions[] | select(.transactionType == "CREATE") | {arguments: (.arguments // []), contractName: .contractName, contractAddress: .contractAddress}')
  echo "Number of 'CREATE' transactions: $(echo "$transactions" | jq -s 'length')"

  chainId=$(echo "$deployment" | jq -r '.chain')
  echo "Chain ID: $chainId"

  if [ -z "$transactions" ]; then
    echo "No 'CREATE' transactions found in the current deployment."
    continue
  fi

  echo "$transactions" | while IFS= read -r transaction; do
    contractName=$(echo "$transaction" | jq -r '.contractName')
    contractAddress=$(echo "$transaction" | jq -r '.contractAddress')
    args=$(echo "$transaction" | jq -r '.arguments // [] | map(if test("^0x[0-9a-fA-F]+$") or test("^[0-9]+$") then . else @sh end) | join(" ")')

    contract_json="./out/${contractName}.sol/${contractName}.json"

    if [ ! -f "$contract_json" ]; then
      echo "JSON file for contract $contractName not found at $contract_json."
      continue
    fi

    constructor_inputs=$(jq -c '.abi[] | select(.type == "constructor") | .inputs' "$contract_json")

    if [ -z "$constructor_inputs" ]; then
      echo "No constructor inputs found for contract $contractName."
      forge verify-contract "$contractAddress" "$contractName" --chain-id "$chainId" --watch || echo "Error verifying contract $contractName at address $contractAddress on chain $chainId."
      continue
    fi

    input_types=$(echo "$constructor_inputs" | jq -r 'map(.type) | join(",")')
    constructor_string="constructor($input_types)"

    if ! encoded_args=$(cast abi-encode "$constructor_string" $args 2>/dev/null); then
      echo "Error encoding arguments for $contractName with constructor $constructor_string."
      continue
    fi

    forge verify-contract "$contractAddress" "$contractName" --constructor-args $encoded_args --chain-id "$chainId" --watch
  done
done

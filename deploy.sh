#!/bin/bash
source .env

get_env_value() {
    grep "^$1=" .env | cut -d= -f2-
}

script_directory="script/deploy"

while true; do
    RPC_URL="missing url" 

    # Extract rpc_endpoints keys from the TOML file
    endpoints=$(awk '/\[rpc_endpoints\]/ {flag=1; next} /\[/{flag=0} flag && !/^$/{print $1}' foundry.toml)

    # Convert the endpoints to an array
    IFS=$'\n' read -r -d '' -a endpoint_array <<<"$endpoints"

    echo "Please select an RPC endpoint:"
    select network in "${endpoint_array[@]}"; do
        if [ -n "$network" ]; then
            # Extract the value of the selected key from the environment variables
            RPC_URL=$(awk -v key="$network" -F' *= *' '$1 == key {gsub(/"/, "", $2); print $2}' foundry.toml | sed 's/\${//;s/}//')
            RPC_URL=$(get_env_value "$RPC_URL")
            echo $RPC_URL
            break
        else
            echo "Invalid selection."
        fi
    done
    echo

    file="./deployment/"$network".json"

    if [ -e "$file" ]; then
        echo "$file found"
    else
        touch "$file"
        echo "$file created."
    fi
    echo

    echo "Select a script"

    files=("$script_directory"/*)

    select script_name in "${files[@]}"; do
        break
    done
    echo

    echo "Configuration:" 
    echo "  RPC: $RPC_URL" 
    echo "  Network: $network" 
    echo "  Script Name: $script_name"
    echo
    echo "Continue?"
    select answer in "yes" "no"; do
        case $answer in
            yes ) deploying=true; break;;
            no ) exit;;
        esac
    done
    echo

    make deploy SCRIPT_NAME=$script_name RPC=$RPC_URL NETWORK=$network

    echo "Deploy Something else?"
    select answer in "yes" "no"; do
        case $answer in
            yes ) break;;
            no ) exit;;
        esac
    done
    echo

done


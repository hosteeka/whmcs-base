#!/usr/bin/env bash
set -Eeuo pipefail

# Change to the directory of this script
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# Start a loop that reads the 'versions.txt' file line by line and generates a JSON object
json='{}'
while IFS= read -r line; do
    # If the line starts with a '#', skip it
    if [[ $line == \#* ]]; then
        continue
    fi
    
    # Split the line into an array
    IFS=',' read -r -a array <<< "$line"

    # Get the first element of the array (WHMCS version)
    whmcsVersion=${array[0]}
    export whmcsVersion

    # The rest of the elements in the array are PHP versions
    phpVersions=${array[@]:1}

    # Generate different variants for each web server and PHP version
    variants='[]'
    for webServer in apache nginx; do
        for phpVersion in $phpVersions; do
            export webServer phpVersion
            variants="$(jq <<< "$variants" -c '. + [ env.webServer + "/php-" + env.phpVersion ]')"
        done
    done

    # Add the WHMCS version and variants to the JSON object
    echo "WHMCS Version: $whmcsVersion"
    json="$(
        jq <<< "$json" -c --argjson variants "$variants" '
            .[env.whmcsVersion] = {
                "variants": $variants
            }
        '
    )"
done < versions.txt

jq <<< "$json" -S . > versions.json

#!/usr/bin/env bash
set -Eeuo pipefail

[ -f versions.json ] # run "versions.sh" first to generate this file

# Download jq-template.awk from bashbrew repo
# https://github.com/docker-library/bashbrew/blob/master/scripts/jq-template.awk
jqt='.jq-template.awk'
wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/9f6a35772ac863a0241f147c820354e4008edf38/scripts/jq-template.awk'

# Get the versions from versions.json if no arguments are passed to this script
if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

# Generate warning message
generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

rm -rf [0-9]* # removes all directories starting with a number (version numbers)

# Generate the Dockerfile for each version and variant
for version; do
    export version

    # Skip versions that don't exist in versions.json
    if jq -e '.[env.version] | not' versions.json > /dev/null; then
        echo "Skipping $version ..."
        continue
    fi

    # Get the variants for this version
    variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
    eval "variants=( $variants )"

    for dir in "${variants[@]}"; do
        # Get the web server and php version
        webServer="$(dirname "$dir")" # "apache", etc
        phpVersion="$(basename "$dir")" # "php-7.4", etc
        phpVersion="${phpVersion#php-}" # "7.4", etc
        export webServer phpVersion

        # Set the from image based on the web server
        if [ "$webServer" != "apache" ]; then
            from="php:$phpVersion-fpm"
        else
            from="php:$phpVersion-apache"
        fi
        export from
        
        # Create the directory for this version
        echo "Processing $version/$dir ..."
        mkdir -p "$version/$dir"

        # Generate the Dockerfile
        {
            generated_warning
            gawk -f "$jqt" 'Dockerfile-linux.template'
        } > "$version/$dir/Dockerfile"
    done
done

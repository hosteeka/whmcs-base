#!/usr/bin/env bash
set -Eeuo pipefail

[ -f versions.json ] # run "versions.sh" first

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
	jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "$BASH_SOURCE" -nt "$jqt" ]; then
	# https://github.com/docker-library/bashbrew/blob/master/scripts/jq-template.awk
	wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/9f6a35772ac863a0241f147c820354e4008edf38/scripts/jq-template.awk'
fi

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

for version; do
    export version

    rm -rf "$version"

    # Skip versions that don't exist in versions.json
    if jq -e '.[env.version] | not' versions.json > /dev/null; then
        echo "Deleting $version ..."
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
        
        echo "Processing $version/$dir ..."
        mkdir -p "$version/$dir"

        # Generate the Dockerfile
        {
            generated_warning
            gawk -f "$jqt" 'Dockerfile-linux.template'
        } > "$version/$dir/Dockerfile"
    done
done

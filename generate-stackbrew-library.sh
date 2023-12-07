#!/usr/bin/env bash
set -Eeuo pipefail

# Change to the directory of this script
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# The filename of this script
self="$(basename "$BASH_SOURCE")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'to_entries | map(if .value then .key | @sh else empty end) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

# Sort version numbers with highest first
IFS=$'\n'; set -- $(sort -rV <<<"$*"); unset IFS

# Get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# Get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

cat <<-EOH
# This file is generated via https://github.com/hosteeka/whmcs-base/blob/$(fileCommit "$self")/$self

Maintainers: Melvin Otieno <o.melvinotieno@gmail.com> (@melvinotieno)
GitRepo: https://github.com/hosteeka/whmcs-base.git
EOH

for version; do
	export version

	# Skip versions that don't exist in versions.json
	if jq -e '.[env.version] | not' versions.json > /dev/null; then
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

		# Check if Dockerfile exists in this directory
		dir="$version/$dir"
		[ -f "$dir/Dockerfile" ] || continue

		# Get the commit for this directory
		commit="$(dirCommit "$dir")"

		echo
		cat <<-EOE
			Tags: $version-$webServer-php$phpVersion
			GitCommit: $commit
			Directory: $dir
		EOE
	done
done

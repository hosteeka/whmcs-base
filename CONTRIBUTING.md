# Contributing to this repository

### For changes to the Dockerfiles

1. Don't edit the Dockerfiles directly. They are generated using templates.
2. Make any changes to the `Dockerfile-linux.template` file in the root of the repository.
3. Follow the instructions under [Testing the changes](#testing-the-changes) and check for desired effect.
4. Commit the changes made to the `Dockerfile-linux.template` file.
5. Do not commit any generated files. These will be generated automatically when the pull request is merged.

### To include a new WHMCS version

1. Add the new WHMCS version to the `versions.txt` file in the root of the repository with the respective PHP versions that are supported by WHMCS.
2. Run the command `./versions.sh` and check if the new version has been added to the `versions.json` file.
3. Commit the changes made to the `versions.txt` file.
4. Do not commit any generated files. These will be generated automatically when the pull request is merged.

## Testing the changes

First, you will need the following software packages to run the [`./apply-templates.sh`](/apply-templates.sh) script.

- [GNU awk](https://www.gnu.org/software/gawk/) available as `gawk`.
- [`jq`](https://stedolan.github.io/jq/)
- A recent version of Bash

Then, run the following command and make sure the generated Dockerfiles are as expected.

```bash
./apply-templates.sh
```

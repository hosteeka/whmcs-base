[![Publish Docker Images](https://github.com/hosteeka/whmcs-base/actions/workflows/publish.yml/badge.svg)](https://github.com/hosteeka/whmcs-base/actions/workflows/publish.yml)

## Maintained by: [Hosteeka](https://github.com/hosteeka/whmcs-base)

This Git repo is used to generate base WHMCS Docker images for different PHP versions and Web Servers. The official support matrix for the different PHP versions can be found in the [WHMCS documentation](https://docs.whmcs.com/PHP_Version_Support_Matrix). However, the images built from this repo are not officially supported by WHMCS.

In these images, we aim to provide the bare minimum to run WHMCS as per the [System Requirements](https://docs.whmcs.com/System_Requirements) in the WHMCS documentation. The exception to this is that we do not include the [ionCube Loader](https://www.ioncube.com/loaders.php) in the images. This is for flexibility on the part of the user to choose which version of the ionCube Loader they wish to use. The version compatibility for the ionCube Loader can be found [here](https://docs.whmcs.com/System_Environment_Guide#Version_Compatibility_3).

You can follow the [System Environment Guide](https://docs.whmcs.com/System_Environment_Guide) and [Further Security Steps](https://docs.whmcs.com/Further_Security_Steps) in the WHMCS documentation to further build on these images.

Note: The WHMCS files are not included in these images since you require a valid WHMCS license to download the files. You will need to download the files and mount them into your image that is built from these base images.

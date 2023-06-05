# Building the image without root permissions on the Linux build-host
* Prerequisits:
  * a RHEL system running on RHEL8 
  * have `rhel-8-for-x86_64-appstream-rpms` and `rhel-8-for-x86_64-baseos-rpms` repositories enabled
  * `podman` and `buildah` installed

## Build the image:

* Copy `build-kerberos-tooling.sh` to your desired location.
* Change `TAG` in the script to match your repository
* Run the following command:
  ```sh
  % buildah unshare sh ./build-kerberos-tooling.sh
  ```
* Push the image to your registry
  ```sh
  % podman push <your_tag>
  ```

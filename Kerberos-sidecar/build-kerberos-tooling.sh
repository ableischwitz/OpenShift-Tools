#! /bin/bash
# Author: Andreas Bleischwitz
# Purpose: Build a container to be used for testing kerberos connectivity inside a POD

set -o pipefail
set -o errexit
set -x

TAG=quay.io/ableisch/openshift-tools:ubi-micro-kerberos-client-0.2

microcontainer=$(buildah from registry.access.redhat.com/ubi8/ubi-micro)
export microcontainer

buildah config \
        --author "ableisch@redhat.com" \
        --created-by "ableisch" \
        --label description="Simple Kerberos clientr image to test Kerberos client connectivity" \
        --label io.k8s.description="Simple Kerberos client image to test Kerberos client connectivity" \
        --label name=rhel-ubi8-kerberos-client \
        $microcontainer

micromount=$(buildah mount $microcontainer)

dnf install \
  --noplugins \
  --assumeyes \
  --installroot $micromount \
  --releasever 8 \
  --setopt install_weak_deps=false \
  krb5-workstation vim-enhanced curl iproute iputils nmap nmap-ncat

dnf clean all \
  --noplugins \
  --installroot $micromount

echo -ne '#! /bin/sh\necho "started sidecar container"\ntrap : TERM INT\nsleep infinity\necho "reached infinity..."\n' > ${micromount}/init.sh
buildah run $microcontainer chmod a+x /init.sh
# delete changed CCACHE setting from default krb5.conf
buildah run $microcontainer sed -e '/default_ccache_name/ d' -i /etc/krb5.conf

buildah config --cmd '["/init.sh"]' $microcontainer

buildah umount $microcontainer

buildah commit $microcontainer $TAG

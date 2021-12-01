### amacdexp/nfs-server-s3-support
FROM alpine:latest

#Inspired to combine follow examples to create  NFS server with backend AWS  S3 support
# 1) https://github.com/sjiveson/nfs-server-alpine/blob/master/Dockerfile
# 3) https://github.com/freegroup/kube-s3/blob/master/Dockerfile


###############################################################################
# The NFS & FUSE driver need elevated privileges, run Docker with --privileged=true
###############################################################################


FROM alpine:latest

ARG NFS_SHARED_PATH=/nfs-shared/default
ENV S3_MNT_POINT=/nfs-shared/s3
ENV IAM_ROLE=none
ENV S3_REGION ''
ARG S3FS_VERSION=v1.89


## Testing on local machine , if not added then "exportfs: <PATH> does not support NFS export"
VOLUME ${NFS_SHARED_PATH}

RUN mkdir -p ${NFS_SHARED_PATH} && \
    chmod 777 ${NFS_SHARED_PATH} && \
    mkdir -p /tmp/sf3_cache && \
    mkdir -p ${S3_MNT_POINT} && \
    chmod 777 ${NFS_SHARED_PATH} && \
    /bin/sh -c "echo '${S3_MNT_POINT} *(rw,fsid=0,no_subtree_check,no_auth_nlm,insecure,no_root_squash)' >> /etc/exports" && \
    /bin/sh -c "echo '${NFS_SHARED_PATH} *(rw,fsid=0,no_subtree_check,no_auth_nlm,insecure,no_root_squash)' >> /etc/exports"
## NOTE at the moment a kubernetes NFS PV  only recognises the first exports path


## PRE-REQ for NFS
RUN apk add --no-cache --update --verbose nfs-utils bash iproute2 && \
    rm -rf /var/cache/apk /tmp /sbin/halt /sbin/poweroff /sbin/reboot && \
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
    echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab



## PRE-REQ for S3
RUN apk --update add bash fuse libcurl libxml2 libstdc++ libgcc alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr  --build=x86_64-unknown-linux-gnu --disable-dependency-tracking; \
    #./configure --prefix=/usr ; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN sed -i s/"#user_allow_other"/"user_allow_other"/g /etc/fuse.conf


COPY nfs-s3-startup.sh /usr/bin/nfs-s3-startup.sh

RUN chmod +x /usr/bin/nfs-s3-startup.sh

# Export NFS Ports
EXPOSE 20048/tcp 2049/tcp

VOLUME ${S3_MNT_POINT}

ENTRYPOINT ["/usr/bin/nfs-s3-startup.sh"]

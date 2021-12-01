# Test of NFS server with S3 backend

Inspired to combine follow examples to create  NFS server with backend AWS  S3 support 


Source references:

[sjiveson/nfs-server-alpine](https://github.com/sjiveson/nfs-server-alpine/blob/master/Dockerfile) 

[freegroup/kube-s3](https://github.com/freegroup/kube-s3/blob/master/Dockerfile) 




The image is available here to try:

[Dockerhub amacdexp/nfs-server-s3-support](https://hub.docker.com/repository/docker/amacdexp/nfs-server-s3-support)



To see an example of this deployed in Kyma  (Kubernetes)   see:

[amacdexp/kyma-storage-options](https://github.com/amacdexp/kyma-storage-options)





## Run in Docker
```
docker run -t -i --privileged \
-e S3_REGION=eu-central-1 \
-e AWS_KEY='your key here' \
-e AWS_SECRET_KEY='your secret here' \
-e S3_BUCKET='your bucket name here. e.g kymastore' \
amacdexp/nfs-server-s3-support /bin/bash

```

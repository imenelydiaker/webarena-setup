#!/bin/bash

# download the archives from the webarena instructions
# https://github.com/web-arena-x/webarena/tree/main/environment_docker

# shopping_final_0712.tar
# shopping_admin_final_0719.tar
# postmill-populated-exposed-withimg.tar
# gitlab-populated-final-port8023.tar

docker load --input /datadrive/shopping_final_0712.tar
docker load --input /datadrive/shopping_admin_final_0719.tar
docker load --input /datadrive/postmill-populated-exposed-withimg.tar
docker load --input /datadrive/gitlab-populated-final-port8023.tar
docker load --input /datadrive/openstreetmap-website-db.tar.gz
docker load --input /datadrive/openstreetmap-website-web.tar.gz


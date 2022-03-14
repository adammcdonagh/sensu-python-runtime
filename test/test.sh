#!/bin/bash

# This assumes that you've built a sensu runtime package already
# The sensu agent docker container runs on alpine, so needs that build
PYTHON_VERSION=${1:-3.9.10}
SHA512=${2:-9a109f2c5f3d3f1db86cf076db65b4a433c2c9732981aac06e45f77ccf2ab4ac79260deea1c289b82a160bb5d90849a478d98f428c4dfdb595f4207966a32be9}
echo $PYTHON_VERSION
# Run docker compose
docker-compose up -d
BACKEND_NAME=test-backend-1

# Give the containers a second to startup
sleep 5

# configure sensuctl
docker exec ${BACKEND_NAME} sensuctl configure -n --url http://localhost:8080 --password password --username admin

# Get the SHA512 sum values
SHA512_ALPINE=`openssl dgst -sha512 ../dist/sensu-python-runtime_local-build_python-${PYTHON_VERSION}_with_requests-alpine_linux_amd64.tar.gz | awk {'print $NF'}`
SHA512_RHEL=`openssl dgst -sha512 ../dist/sensu-python-runtime_local-build_python-${PYTHON_VERSION}_with_requests-rhel_linux_amd64.tar.gz | awk {'print $NF'}`

# Load bonsai asset
docker exec -i ${BACKEND_NAME} sensuctl create <<EOF
---
type: Asset
api_version: core/v2
metadata:
  name: core/python_with_requests
spec:
  builds:
    - sha512: ${SHA512_ALPINE}
      url: http://bonsai-server.local/sensu-python-runtime_local-build_python-${PYTHON_VERSION}_with_requests-alpine_linux_amd64.tar.gz
      filters:
      - entity.system.os == 'linux'
      - entity.system.arch == 'amd64'
      - entity.system.platform_family == 'alpine'
    - sha512: ${SHA512_RHEL}
      url: http://bonsai-server.local/sensu-python-runtime_local-build_python-${PYTHON_VERSION}_with_requests-rhel_linux_amd64.tar.gz
      filters:
      - entity.system.os == 'linux'
      - entity.system.arch == 'amd64'
      - entity.system.platform_family == 'rhel'
EOF

# Add a check that uses the asset
docker exec -i ${BACKEND_NAME} sensuctl create <<EOF
---
type: CheckConfig
api_version: core/v2
metadata:
  name: check-python-requests
spec:
  command: "python --version"
  runtime_assets:
  - core/python_with_requests
  subscriptions:
  - unix
  interval: 10
  timeout: 5
  publish: true
EOF

sleep 10

# Get entity check results to verify that checks are running OK

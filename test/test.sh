#!/bin/bash

# This assumes that you've built a sensu runtime package already
# The sensu agent docker container runs on alpine, so needs that build
PYTHON_VERSION=${1:3.9.10}
SHA512=${2:c03bfa9cb9e6e631eccee50b7273bb7840a6d05c3e32b4c71e9b42b5d3f9caf666f554efcf1f58ba3e40a7d68bbd2af631a962ea8eb0ed8e23d69f820dae4001}

# Run docker compose
docker-compose up -d

# configure sensuctl
docker exec test-sensu-backend sensuctl configure -n --url http://localhost:8080 --password password --username admin

# Load bonsai asset
docker exec -i test-sensu-backend sensuctl create <<EOF
---
type: Asset
api_version: core/v2
metadata:
  name: core/python_with_requests
spec:
  builds:
    - sha512: ${SHA512}
      url: http://bonsai-server/sensu-python-runtime_local-build_python-${PYTHON_VERSION}_with_requests-alpine_linux_amd64.tar.gz
EOF

# Add a check that uses the asset
docker exec -i test-sensu-backend sensuctl create <<EOF
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
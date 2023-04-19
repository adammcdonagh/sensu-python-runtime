#!/bin/bash

mkdir -p dist
mkdir -p assets
mkdir -p scripts

# comma separated list of package groups
packages=`echo "requests,requests boto3,bofhexcuse" | base64`

# Alpine platform
echo "Building for Alpine and Python packages: ${packages}"
platform="alpine" test_platforms="alpine:latest" ./build_and_test_platform.sh $packages
retval=$?
if [[ $retval -ne 0 ]]; then
  exit $retval
fi

# RHEL platform - Use Alma Linux to simulate RHEL8
echo "Building for RHEL and Python packages: ${packages}"
platform="rhel8" test_platforms="almalinux:latest" ./build_and_test_platform.sh ${packages}
retval=$?
if [[ $retval -ne 0 ]]; then
  exit $retval
fi

# RHEL platform - Use Alma Linux to simulate RHEL7
echo "Building for RHEL7 and Python packages: ${packages}"
platform="rhel7" test_platforms="centos:7" ./build_and_test_platform.sh ${packages}
retval=$?
if [[ $retval -ne 0 ]]; then
  exit $retval
fi

# AMZN2 platform - Amazon Linux 2
echo "Building for RHEL and Python packages: ${packages}"
platform="amzn2" test_platforms="amazonlinux:latest" ./build_and_test_platform.sh ${packages}
retval=$?
if [[ $retval -ne 0 ]]; then
  exit $retval
fi

exit 0

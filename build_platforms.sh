#!/bin/bash

# export ROOT_CA to a proxy Root CA before running if there's root CA that needs trusting
test -e root_ca.pem && export ROOT_CA=root_ca.pem

mkdir -p dist
mkdir -p assets
mkdir -p scripts

# Blank space is intentional!
packages=("." "requests" "boto3")

# Alpine platform
for package in ${packages[@]}; do
  echo "Building for Alpine and Python packages: ${package}"  
  platform="alpine" test_platforms="alpine:latest" packages="${package}" ./build_and_test_platform.sh
  retval=$?
  if [[ $retval -ne 0 ]]; then
    exit $retval
  fi
done

# # RHEL platform - Use Alma Linux to simulate RHEL8
# for package in ${packages[@]}; do
#   echo "Building for RHEL and Python packages: ${package}"  
#   platform="rhel" test_platforms="almalinux:latest" packages="${package}" ./build_and_test_platform.sh
#   retval=$?
#   if [[ $retval -ne 0 ]]; then
#     exit $retval
#   fi
# done

# # AMZN2 platform - Amazon Linux 2
# for package in ${packages[@]}; do
#   echo "Building for RHEL and Python packages: ${package}"  
#   platform="amzn2" test_platforms="amazonlinux:latest" packages="${package}" ./build_and_test_platform.sh
#   retval=$?
#   if [[ $retval -ne 0 ]]; then
#     exit $retval
#   fi
# done

exit 0


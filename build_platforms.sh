#!/bin/bash

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
  if [[ retval -ne 0 ]]; then
    exit $retval
  fi
done

# RHEL platform
for package in ${packages[@]}; do
  echo "Building for RHEL and Python packages: ${package}"  
  platform="rhel" test_platforms="centos:7 amazonlinux:latest" packages="${package}" ./build_and_test_platform.sh
  retval=$?
  if [[ retval -ne 0 ]]; then
    exit $retval
  fi
done

exit 0


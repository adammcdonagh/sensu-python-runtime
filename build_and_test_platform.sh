#!/bin/bash -x
packages=$1
ignore_errors=0
python_version=3.9.10
asset_version=${TAG:-local-build}
# package_list=`[ "${packages}" != "." ] && echo _with_${packages} | sed 's/ /_/g' || echo _vanilla`

#determine the architecture
ARCH=x86_64
# Handle Apple M1 chip
uname -a | grep Darwin | grep arm64 && ARCH=aarch64

# asset_filename=sensu-python-runtime_${asset_version}_python-${python_version}${package_list}-${platform}_linux_${ARCH}.tar.gz
asset_image=sensu-python-runtime-${python_version}-${platform}-${ARCH}:${asset_version}


if [ "${asset_version}" = "local-build" ]; then
  echo "Local build"
  ignore_errors=1
fi

proxy_build_args=
if [ ! -z ${HTTP_PROXY} ]; then
  proxy_build_args="--build-arg HTTP_PROXY=${HTTP_PROXY} --build-arg HTTPS_PROXY=${HTTPS_PROXY} --build-arg ROOT_CA=${ROOT_CA}"
  cert_mount="-v ${PWD}/${ROOT_CA}:/etc/pki/ca-trust/source/anchors/proxy_ca.pem"
fi

echo "Platform: ${platform}"
echo "Check for asset file: ${asset_filename}"
# if [ ! -f "$PWD/dist/${asset_filename}" ]; then
#   echo "File: "$PWD/dist/${asset_filename}" already exists!!!"
#   [ $ignore_errors -eq 0 ] && exit 1  
# else
echo "Check for docker image: ${asset_image}"
if [[ "$(docker images -q ${asset_image} 2> /dev/null)" == "" ]]; then
  echo "Docker image not found...we can build"
  echo "Building Docker Image: ${asset_image}"
  docker build --build-arg "PYTHON_VERSION=${python_version}" ${proxy_build_args} --build-arg ASSET_VERSION=${asset_version} --build-arg PACKAGES=${packages} --build-arg PLATFORM=${platform} -t ${asset_image} -f Dockerfile.${platform} .
  retval=$?
  if [[ $retval -ne 0 ]]; then
    # Delete the image
    docker image rm ${asset_image} 2>/dev/null
    exit $retval
  fi
  echo "Making Asset: /assets/${asset_filename}"
  docker run --rm -v "${PWD}/dist:/dist" ${asset_image} sh -c "cp /assets/* /dist/"
#    #rm $PWD/test/*
#    #cp $PWD/dist/${asset_filename} $PWD/dist/${asset_filename}
else
  echo "Image already exists!!!"
  [ $ignore_errors -eq 0 ] && exit 1  

fi

test_arr=($test_platforms)
for test_platform in "${test_arr[@]}"; do

  # Check container doesnt exist, if it does, remove it
  docker container list --all -f name=python_runtime_platform_test | grep python_runtime_platform_test && docker container rm python_runtime_platform_test

  echo "Test: ${test_platform}"
  docker run --rm --name python_runtime_platform_test -e python_version=${python_version} -e platform=${platform} -e test_platform=${test_platform} -e asset_version=${asset_version} -v "$PWD/tests/:/tests" -v "$PWD/dist:/dist" ${cert_mount} ${test_platform} /tests/test.sh ${packages}
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "!!! Error testing ${asset_filename} on ${test_platform}"
    exit $retval
  fi
  echo "#################"
  echo "### Test passed"
  echo "#################"
  docker rm python_runtime_platform_test 2>/dev/null
done

if [ -z "$TRAVIS_TAG" ]; then exit 0; fi
if [ -z "$DOCKER_USER" ]; then exit 0; fi
if [ -z "$DOCKER_PASSWORD" ]; then exit 0; fi

docker_asset=${TRAVIS_REPO_SLUG}-${python_version}${package_list}-${platform}:${asset_version}

echo "Docker Hub Asset: ${docker_asset}"
echo "preparing to tag and push docker hub asset"


docker tag ${asset_image} ${docker_asset}



#!/bin/sh
echo "Test Script:"
echo "  Asset Platform:  ${platform}"
echo "  Target Platform: ${test_platform}"
echo "  Python Version:   ${python_version}"



. /etc/os-release
# Ensure tar is installed
echo $ID_LIKE | grep rhel && echo "Installing tar and gzip" && update-ca-trust && yum install -y tar gzip >/dev/null

ARCH=`uname -m`

echo $1 | sed -n 1'p' | tr ',' '\n' | while read packages; do

  packages_no_space=`echo ${packages} | sed 's/ /_/g'`
  asset_filename="sensu-python-runtime_${asset_version}_python-${python_version}_with_${packages_no_space}-${platform}_linux_${ARCH}.tar.gz"
  echo "  Asset Tarball:   ${asset_filename}"
  if [ -z "$asset_filename" ]; then
    echo "Asset is empty"
    exit 1
  fi


  mkdir -p /build
  cd /build
  tar xzf /dist/$asset_filename
  if [ $? -ne 0 ]; then
    exit 1
  fi

  LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" [ "$(/build/bin/python --version)" = "Python ${python_version}" ] || (>&2 echo "Python version does not match"; exit 1)
  if [ $? -ne 0 ]; then
    exit 1
  fi

  LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/test-uuid.py || (>&2 echo "Python UUID test failed"; exit 1)
  if [ $? -ne 0 ]; then
    exit 1
  fi

  LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/module_search_path.py || (>&2 echo "Python module search path test failed"; exit 1)
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # If there are packages, then run those tests too

  echo ${packages} | tr ' ' '\n' | while read package; do

    LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/test-${package}.py || (>&2 echo "Python package ${package} test failed"; exit 1)
    if [ $? -ne 0 ]; then
      exit 1
    fi
  done

  cd /
  rm -r /build

done

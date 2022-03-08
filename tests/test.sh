#!/bin/sh
echo "Test Script:"
echo "  Asset Platform:  ${platform}"
echo "  Target Platform: ${test_platform}"
echo "  Asset Tarball:   ${asset_filename}"
if [ -z "$asset_filename" ]; then
  echo "Asset is empty"
  exit 1
fi

. /etc/os-release
# Ensure tar is installed
echo $ID_LIKE | grep rhel && echo "Installing tar and gzip" && yum install -y tar gzip >/dev/null

mkdir -p /build
cd /build
tar xzf /dist/$asset_filename
if [ $? -ne 0 ]; then
  exit 1
fi

#LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/test_ssl_url.py
LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" [ "$(/build/bin/python --version)" = "Python 3.9.10" ] || (>&2 echo "Python version does not match"; exit 1)
if [ $? -ne 0 ]; then
  exit 1
fi

LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/test-uuid.py || (>&2 echo "Python UUID test failed"; exit 1)
if [ $? -ne 0 ]; then
  exit 1
fi

LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/module_search_path.py || (>&2 echo "Python UUID test failed"; exit 1)
if [ $? -ne 0 ]; then
  exit 1
fi

# If there are packages, then run those tests too
if [ $# != 0 ]; then
  packages=$@
  if [ ! "${packages}" == "." ]; then
    for package in "${packages}"; do
      LD_LIBRARY_PATH="/build/lib:$LD_LIBRARY_PATH" /build/bin/python /tests/test-${package}.py || (>&2 echo "Python package ${package} test failed"; exit 1)
      if [ $? -ne 0 ]; then
        exit 1
      fi
    done
  fi
fi

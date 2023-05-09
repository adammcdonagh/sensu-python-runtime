# Sensu Go Python Runtime Assets

This project provides a portable Python runtime asset that can be used by other Sensu assets.

As detailed in the original repo by @jspaleta:

*In practice, this Python runtime asset should allow Python-based scripts (e.g. [Sensu Community plugins][sensu-plugins]) to be packaged as separate assets containing Python scripts and any corresponding Python module dependencies. In this way, a single shared Python runtime may be delivered to systems running the new Sensu Go Agent via the new Sensu's new Asset framework (i.e. avoiding solutions that would require a Python runtime to be redundantly packaged with every python-based plugin).*

The runtime package is fully built in this repo using GitHub Actions when a tagged commit is pushed to the master branch e.g. `git push origin v1.3.2`

## Workflow

  1. Push as many commits as you want. When it's time to build, tag the commit and push it
  2. Wait for the GitHub Actions to run and verify the work successfully, and build the assets
  3. Do a PR to merge into master
  4. Once the PR is approved and merged, the `deploy` job will be triggered, which will run against each environment.

## Testing

I recommend using `act` to test the GitHub Actions. You can use the original `build_and_test_platform.sh` script, but this has not been maintained since moving to GitHub Actions.

# Defining runtimes

The Python version for the runtime that is built is defined in the `matrix.json` file. Some systems (old ones) will have a maximum supported version (mainly due to OpenSSL library compatability), hence why the RHEL7 based systems are limited to a maximum of Python 3.9.16.

To add a new platform, simply add it to the `matrix.json`.

A vanilla package is always built, which contains no additional Python packages. In addition to this, for each platform, groups of packages are listed. Each group contains 1 or more pip package names, along with a `group_name` which is used in the output asset filename.

# Sensu assets

I have a repo containing basic assets here: [https://github.com/adammcdonagh/sensu-assets](https://github.com/adammcdonagh/sensu-assets)

To automate the build and deploy of the assets themselves, a further repo is used to pull them together and automate testing and the creation of the asset.yml files to import into Sensu: [https://github.com/adammcdonagh/sensu-asset-builder](https://github.com/adammcdonagh/sensu-asset-builder)
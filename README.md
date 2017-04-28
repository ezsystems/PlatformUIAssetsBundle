# Platform UI Assets Bundle

[![Build Status](https://travis-ci.org/ezsystems/PlatformUIAssetsBundle.svg?branch=master)](https://travis-ci.org/ezsystems/PlatformUIAssetsBundle)

The PlatformUIAssetsBundle provides the external frontend dependencies needed by
the eZ Platform UI. The `master` branch only contains some meta files, the actual
dependencies are only available in the tags.


## Install dependencies for dev use

For local dev use _(testing newer packages.json dependencies, ..)_ make sure you have [`bower`](https://bower.io/) installed and run the following:

```bash
$ bower install
```

and follow the instructions.

## Release a new version

Just run the `prepare_release.sh` script:

```bash
$ ./bin/prepare_release.sh -v 0.10
```

and follow the instructions.

## Testing / Developer tasks

Testing of this lib can be done from PlatformUIBundle, see [PlatformUIBundle/README.md](https://github.com/ezsystems/PlatformUIBundle/blob/master/README.md#developers-tasks) for further instructions.

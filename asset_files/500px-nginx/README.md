# 500px-nginx
Uses Vagrant to generate a debian package for nginx. This package tries to be very similar to the
official [packages](http://nginx.org/en/linux_packages.html#mainline) provided by [nginx.org](http://nginx.org/). Currently, the only addition we make is to compile in support for
the [headers more](https://github.com/openresty/headers-more-nginx-module/) module, which is very
handy.

If you are looking for an nginx package, it is highly recomended that you **do not** choose this one.
That would be a super bad idea. We make no gurantees that this works, will continue to work, or
that it won't set your server on fire and kill your family and everyone you love.

Presumably you are reading this because you need to solve a problem. In this case it's way better
to either fork this repo and compile your own nginx so you can own all the parts of it, or use a
distro package (like `nginx-extras` in Ubuntu), or use [openresty](https://openresty.org/en/) which
is rad and cool.

## Configuring
Edit `assets/mkdeb_configure` to configure Debian package metadata to suit your environment. Edit
the bash scripts in `assets` to change how the package installs, upgrades or configures itself.

The init and package scripts are copied essentially verbatim from the official nginx packages.

## Generate a package
Just `vagrant up` to execute the build script. A helper, `build_deb.sh` is available for repeated
builds.

```bash
# contents of build_deb.sh

#!/bin/bash
rm ../../*.deb
vagrant destroy
vagrant up
```

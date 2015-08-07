# mkdeb.sh
mkdeb is a bash wrapper for [FPM](https://github.com/jordansissel/fpm). It solves an incredibly specific problem.

## Overview
mkdeb is a bash wrapper for [FPM](https://github.com/jordansissel/fpm). It is meant to be used in a continuous integration pipeline or other situations that require building relatively uncomplicated packages over and over again. At [500px](https://500px.com) we use [mkdeb and Travis CI](asset_files/travis_versioning) to package all our [Go apps](http://stackshare.io/500px/how-500px-serves-up-over-500tb-of-high-res-photos).

## Requirements, Installation, Excuses
mkdeb requires FPM. FPM is a ruby gem, so you will need to have Ruby and `gem` on the system you want to build the package on. You can download mkdeb and install FPM like this:

```bash
# get the script, make it executable
curl -Ss -O https://raw.githubusercontent.com/pwyliu/mkdeb/master/mkdeb.sh
chmod +x mkdeb.sh

# install FPM
gem install fpm --no-ri --no-rdoc --quiet
```

mkdeb only makes [debian packages](https://www.debian.org/doc/debian-policy/ch-binary.html)

## Usage, Configuration File, Asset Files
`mkdeb.sh` only takes one paramater `-c`, a path to a directory containing a configuration file, `mkdeb_configure`, and the files that mkdeb requires to build the deb. The directory should have a structure like this:

* `assets/` - the top level, can be named anything
  * `preinst.sh` - the package's pre install script
  * `postinst.sh` - the package's post install script
  * `prerm.sh` - the package's pre removal script
  * `postrm.sh` - the package's post removal script
  * `default/` - (optional) a directory containing the default file
    * `mydefaultfile`, the package's default file
  * `upstart/` - (optional) a directory containing the upstart
    * `myupstartfile`, the package's upstart file

Simply invoke mkdeb like this: `./mkdeb.sh -c my_stuff`. Or in a `.travis.yml` you might do something like this:

```
# travis.yml
after_success:
  - '[[ "${TRAVIS_PULL_REQUEST}" == "false" ]] && ./mkdeb.sh -c mkdeb/assets || false'
```

### `mkdeb_configure`
There's a bunch of stuff you can set in mkdeb_configure, see [this example](support/examples/mkdeb_configure.example) for more documentation.

## A Hot Tip About Using Default files
It's not a good idea to bake too much state into packages, but sometimes you want to include some sensible defaults. For daemons, I generally package a default file and then in my Upstart file I have a snippet like this:

```
# /etc/init/coolapp.conf
script
  [ -r /etc/default/coolapp ] && . /etc/default/coolapp
  [ -r /etc/coolapp/server.cfg ] && . /etc/coolapp/server.cfg
  exec start-stop-daemon --start --user coolapp_user --chuid coolapp_user --chdir /opt/coolapp --exec /opt/coolapp/coolapp.bin -- $DAEMON_ARGS
end script
```

Where `$DAEMON_ARGS` was set in `/etc/default/coolapp` or overridden in `/etc/coolapp/server.cfg`. This way you can have something that works out of the box, or write a config with Puppet or Chef or whatever and have that take precedence.

## PR's
I accept them! Do it.

# oauth2_proxy
Uses Vagrant to generate a debian package for the excellent [oauth2_proxy](https://github.com/bitly/oauth2_proxy)
from [bitly](https://bitly.com/).

500px :heart_eyes: oauth2_proxy.

## Configuring
Edit `assets/mkdeb_configure` to configure Debian package metadata to suit your environment. Edit
the bash scripts in `assets` to change how the package installs or upgrades itself.

## Default behaviour
The generated package will install the oauth2_proxy binary to `/opt/oauth2_proxy/oauth2_proxy`, 
install an Upstart script, `/etc/init/oauth2_proxy` and place a dummy configuration file at 
`/etc/oauth2_proxy/oauth2_proxy.cfg`. It also creates a system user for the daemon, creatively 
named `oauth2_proxy`.

You **must** configure oauth2_proxy before you can start the daemon. See https://github.com/bitly/oauth2_proxy#config-file for more details about how to configure this file. It is highly recomended that you secure 
read access to this file, since it will contain oauth secrets.

oauth2_proxy logs are located at `/var/log/upstart/oauth2_proxy.log`

## Making changes
See `Vagrantfile` and `assets/mkdeb_configure` to see what Vagrant and mkdeb are doing to generate
this deb. Check out the scipts in `assets` to see how the package works.

## Generate Debian Package
```bash
vagrant destroy
rm ../../*.deb
vagrant up
# A debian package will be placed in the project root directory.
```

## Package specifics
* Install oauth2_proxy into /opt
* 
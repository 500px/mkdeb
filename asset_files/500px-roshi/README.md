# Roshi
Uses Vagrant to generate a debian package for Roshi. `cd` to this dir, then `vagrant up`. A deb 
package for roshi-server (and roshi-walker) appears in the root of this project on your local 
filesystem.

## Making changes
See `Vagrantfile` and `assets/mkdeb_configure` to see what Vagrant and mkdeb are doing. To make 
changes to how the package actually works, see the scripts in `assets`.

## Regenerate package

```bash
vagrant destroy
rm ../../*.deb
vagrant up
echo "ballertown"
```

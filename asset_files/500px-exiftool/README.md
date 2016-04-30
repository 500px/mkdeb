# Exiftool
Uses Vagrant to generate a debian package for exiftool. `cd` to this dir, then `vagrant up` to
generate the package on your local filesystem in the repo root.

## Making changes
Edit `Vagrantfile` and `assets/mkdeb_configure` to change the build environment and package 
settings.

## Regenerate package

```bash
vagrant destroy
rm ../../*.deb
vagrant up
echo "ballertown"
```

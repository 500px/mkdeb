#!/bin/bash
set -e

case "$1" in
configure)
    perl_lib_dir=$(perl -E "say for @INC" | grep /usr/local/share/perl/)
    chown root:root /usr/local/bin/exiftool
    chmod 0755 /usr/local/bin/exiftool

    chown -R root:root ${perl_lib_dir}/File
    chown -R root:root ${perl_lib_dir}/Image
    chown -R root:root /usr/local/share/exiftool/arg_files
    ;;
esac

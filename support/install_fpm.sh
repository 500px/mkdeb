#!/bin/bash

# installs git, build tools, ruby and then fpm

apt-get install git build-essential ruby ruby-dev
gem install fpm --no-ri --no-rdoc --quiet

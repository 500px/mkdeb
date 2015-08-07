#!/bin/bash

# installs git, build tools, ruby and then fpm

apt-get install -qq -y git build-essential

# Install Ruby 1.9 on Precise. Ruby 1.8 has issues with FPM.
if [[ "$(lsb_release -cs)" == "precise" ]]; then
  apt-get install -qq -y ruby1.9.1 ruby1.9.1-dev
  update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 500
  update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.9.1 500
else
  apt-get install -qq -y ruby ruby-dev
fi

gem install fpm --no-ri --no-rdoc --quiet

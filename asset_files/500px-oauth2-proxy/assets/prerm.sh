#!/bin/bash

# shut process down
if pidof "oauth2_proxy" > /dev/null; then
  service roshi-server stop || exit $?
fi

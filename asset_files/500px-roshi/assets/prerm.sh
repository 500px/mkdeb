#!/bin/bash

# shut process down
if pidof "roshi-server" > /dev/null; then
  service roshi-server stop || exit $?
fi

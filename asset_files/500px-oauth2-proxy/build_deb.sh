#!/bin/bash
rm ../../*.deb
vagrant destroy
vagrant up
vagrant destroy

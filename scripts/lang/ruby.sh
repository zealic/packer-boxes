#!/bin/bash
curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -
curl -L https://get.rvm.io | sudo bash -s stable --autolibs=enabled --ruby

source /usr/local/rvm/scripts/rvm
rvm use ruby

gem install rake bundler

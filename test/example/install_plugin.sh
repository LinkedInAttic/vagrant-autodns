#!/bin/bash

pushd `dirname $0`/../../
  vagrant plugin uninstall vagrant-autodns
  rm -f vagrant-autodns-*.gem
  bundle install
  bundle exec gem build vagrant-autodns.gemspec
  vagrant plugin install vagrant-autodns-*.gem
popd
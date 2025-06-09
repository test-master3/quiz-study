#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Clean assets
bundle exec rake assets:clean

# Compile assets
bundle exec rake assets:precompile

# Setup database
bundle exec rake db:migrate

bundle exec puma -C config/puma.rb 
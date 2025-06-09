#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Clean assets
bundle exec rake assets:clean

# Compile assets
bundle exec rake assets:precompile

# Setup database with environment variable
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
bundle exec rake db:schema:load
bundle exec rake db:migrate
bundle exec rake db:seed

bundle exec puma -C config/puma.rb 
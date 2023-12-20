# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~>3.1.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0"
# Use postgres as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma", "~> 5.6"

gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'
# allow ssh
gem "bcrypt_pbkdf"
gem "ed25519"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "faker"
gem "reform"
gem "reform-rails"
gem "whenever", require: false

# Single sign on
gem "devise"
gem "omniauth-cas"
gem "omniauth-rails_csrf_protection", "~> 0.1"

# workflow
gem "aasm"

# ldap
gem "net-ldap"

# pagination
gem "kaminari"

# static pages
gem "high_voltage", "~> 3.1"

gem "honeybadger"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "bixby", "~> 5.0"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry"
  gem "pry-byebug"
end

group :development do
  gem "capistrano-passenger"
  gem "capistrano-rails"
  gem "capistrano-yarn"
  gem "rails_real_favicon"
  gem "rspec-rails", "~> 4.0.1"
  gem "web-console", ">= 3.3.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "capybara-screenshot"
  gem "factory_bot_rails", require: false
  gem "rails-controller-testing"
  gem "rspec_junit_formatter"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "timecop"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "vite_rails"

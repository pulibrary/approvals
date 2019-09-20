# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~>2.4.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.3"
# Use postgres as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma", "~> 3.11"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "faker"
gem "reform"
gem "reform-rails"
gem "webpacker", ">= 4.0.x"
gem "whenever", require: false

# Single sign on
gem "devise"
gem "omniauth-cas"

# workflow
gem "aasm"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "bixby"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry"
  gem "pry-byebug"
end

group :development do
  gem "capistrano-passenger"
  gem "capistrano-rails", "~> 1.1.6"
  gem "foreman"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rspec-rails", "~> 3.8"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
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
  gem "webdrivers", "~> 3.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

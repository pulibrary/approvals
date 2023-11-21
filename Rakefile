# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# Prevent rake assets:precompile from installing all yarn dependencies
# and devDependencies during deployment (since we only need the dependencies,
# not the devDependencies)
Rake::Task["yarn:install"].clear

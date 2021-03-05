# frozen_string_literal: true

# config valid only for Capistrano 3.1
lock '>=3.2.1'

set :application, 'approvals'
set :repo_url, 'https://github.com/pulibrary/approvals.git'

# gets overriden to development on staging deploy
set :branch, 'master'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/opt/approvals'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true
set :branch, ENV["BRANCH"] || "main"


shared_path = "#{:deploy_to}/shared"
# set :assets_prefix, '#{shared_path}/public'

## removing the following from linked files for the time being
# config/redis.yml config/devise.yml config/resque_pool.yml, config/recipients_list.yml, log/resque-pool.stderr.log log/resque-pool.stdout.log

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{tmp/pids tmp/sockets log}


# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :default_env, { path: "/home/vagrant/.rvm/gems/ruby-x.x.x/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :passenger_restart_with_touch, true

namespace :approvals do

  desc 'reset the database and reseed'
  task :reset do
    on roles(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :sudo, '/usr/sbin/service nginx stop'
          execute :rake, 'db:drop db:create db:migrate'
          execute :sudo, '/usr/sbin/service nginx start'
          # we process the locations twice when the database is empty, since there is a chicken and egg situation
          #  The location needs to exist to attche an AA to it, but the AA must exist to attach it to a location.
          #  The location processing just ignores an AA that does not exists, so if we run it once the locations 
          #  exists to connect with the new people.  If we run it again after the people exists it connects the AAs.
          execute :rake, 'approvals:load_locations'
          execute :rake, 'approvals:process_reports'
          execute :rake, 'approvals:load_locations'
          execute :rake, 'approvals:make_requests_for_everyone'
        end
      end
    end 
  end

  desc 'Process the staff report now'
  task :process_reports do
    on roles(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, 'approvals:process_reports'
        end
      end
    end 
  end

  desc 'Make Requests for everyone this can take a very long time'
  task :make_requests_for_everyone do
    on roles(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, 'approvals:make_requests_for_everyone'
        end 
      end 
    end 
  end

  desc 'Make Requests for a specific user'
  task :make_requests_for_user, [:netid] do |_t, args|
    netid = args[:netid]
    on roles(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, "approvals:make_requests_for_user[#{netid}]"
        end 
      end 
    end 
  end

  desc 'Add fake users to give [:netid] someone to supervise'
  task :make_me_a_supervisor, [:netid, :number] do |_t, args|
    netid = args[:netid]
    number = args[:number]
    on roles(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, "approvals:make_me_a_supervisor[#{netid},#{number}]"
        end 
      end 
    end 
  end
end



namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

# TODO - We likely need a robot.txt
#   task :robots_txt do
#     on roles(:app) do
#       within release_path do
#         execute :rake, 'pulsearch:robots_txt'
#       end
#     end
#   end
#   after :publishing, :restart
#   after :publishing, :robots_txt

  after :finishing, 'deploy:cleanup'

  # # We shouldn't need this because it should be built in to Rails 5.1
  # # see https://github.com/rails/webpacker/issues/1037
  # desc 'Run yarn install'
  # task :yarn_install do
  #   on roles(:web) do
  #     within release_path do
  #       execute("cd #{release_path} && yarn install")
  #     end
  #   end
  # end
  # before "deploy:assets:precompile", "deploy:yarn_install"
end
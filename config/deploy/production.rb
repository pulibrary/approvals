# frozen_string_literal: true

set :rvm_ruby_string, :local # use the same ruby as used locally for deployment
set :rails_env, "production"

# server "lib-approvals-prod1", user: "deploy", roles: %i[web app db]
server "lib-approvals-prod1", user: "deploy", roles: %i[web app db]

namespace :env do
  desc "Set all Approvals environment variable"
  task :set do |_task, args|
    on roles(:app) do
      abort "Environment variables and values must be specified. `env:set['ENV_VAR=value']`" if args.extras.empty?
      config_file = "/home/deploy/app_configs/approvals"
      args.extras.each do |arg|
        variable, value = arg.split("=", 2)
        abort "Environment variable and value must be specified. `env:set['ENV_VAR=value']`" if value.nil?
        within release_path do
          execute("sed -i -e 's/#{variable}=.*/#{variable}=#{value.gsub('/', '\/')}/' #{config_file}")
        end
      end

      # Print out app_config file
      within release_path do
        execute :cat, config_file
      end

      # Restart passenger
      invoke "deploy:restart"
    end
  end
end

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :web, "hubba.retina.net"
role :app, "hubba.retina.net"

set :log_level, :debug
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

#set :rbenv_type, :user # or :system, depends on your rbenv setup
#set :rbenv_ruby, '2.1.4-p265'
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
#set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#set :rbenv_roles, :all # default value

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'hubba.retina.net', user: 'deploy', roles: %w{web app}

# Global options
# --------------
set :ssh_options, {
   keys: %w(/retina/hubba/showmanager/keys/deploy.key),
   forward_agent: false,
   user: 'deploy',
   auth_methods: %w(publickey)
}

set :tests, []

set :linked_files, %w{config/initializers/secret_token.rb}

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
      puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  # only allow a deploy with passing tests to deployed
  # make sure we're deploying what we think we're deploying
  before :deploy, "deploy:check_revision"

  # we don't need any stinking tests.
  #before :deploy, "deploy:run_tests"

  # compile assets locally then rsync
  #after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  #after :finishing, 'deploy:cleanup'

  after 'deploy:publishing', 'nginx:restart'
end

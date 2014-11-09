# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :web, "hubba.retina.net"
role :app, "hubba.retina.net"

set :log_level, :debug

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

namespace :deploy do
  # make sure we're deploying what we think we're deploying
  before :deploy, "deploy:check_revision"

  # only allow a deploy with passing tests to deployed
  #before :deploy, "deploy:run_tests"

  # compile assets locally then rsync
  #after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  #after :finishing, 'deploy:cleanup'

  after 'deploy:publishing', 'nginx:restart'
end
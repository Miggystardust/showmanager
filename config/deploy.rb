ssh_options[:keys] = %w(/Users/jna/.ec2/jna-ec2.pem)

set :application, "hubba.retina.net"
set :repository,  "git@github.com:netik/showmanager"

set :scm, :git
set :deploy_via, :copy

set :user, "ubuntu"
set :deploy_to, "/retina/hubba/showmanager-cap"

set :use_sudo, true

role :web, "hubba.retina.net"
role :app, "hubba.retina.net"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
    run "sudo service nginx start"
  end
  
  task :stop do
    run "sudo service nginx stop"
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :gems do
  task :install do
    run "cd #{deploy_to}/current && RAILS_ENV=production bundle install"
  end
end

# don't need to do this all the time do we 
# after :deploy, "gems:install"


# makes local commands look more cap-like
def run_local cmd
  puts %[ * executing locally "#{cmd}"]
  `#{cmd}`
end

namespace :ec2 do
  task :get_public_key do
    host = find_servers_for_task(current_task).first.host
    privkey = ssh_options[:keys][0]
    pubkey = "#{privkey}.pub"
    run_local "scp -i '#{privkey}' ubuntu@#{host}:.ssh/authorized_keys #{pubkey}"
  end
end

task :sudo_test do
  run "#{try_sudo} whoami"
end

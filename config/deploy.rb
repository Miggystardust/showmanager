load 'deploy/assets'

ssh_options[:keys] = %w(/Users/jna/.ec2/jna-ec2.pem)
ssh_options[:user] = 'ubuntu'
#ssh_options[:verbose] = :debug
#set :scm_verbose, true

default_run_options[:pty] = true 

set :scm, :git
set :application, "hubba.retina.net"
set :repository,  "https://github.com/netik/showmanager.git"

set :deploy_via, :remote_cache
set :deploy_to, "/retina/hubba/showmanager-cap"
set :user, "ubuntu"
set :runner, "ubuntu"

set :use_sudo, true

role :web, "hubba.retina.net"
role :app, "hubba.retina.net"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end

  task :before_update_code, :roles => :app do 
    run "whoami" 
  end 

  task :start do
    run "sudo service nginx start"
  end
  
  task :stop do
    run "sudo service nginx stop"
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    # passenger will pick up the code when this exists
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

desc "install the necessary prerequisites"

task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"

end

after "deploy:update_code", :bundle_install

task :sudo_test do
  run "#{try_sudo} whoami"
end

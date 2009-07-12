default_run_options[:pty] =  true   #REASON: http://www.mail-archive.com/capistrano@googlegroups.com/msg02817.html
set :application, "yeeyay"
set :repository, "git@github.com:hariis/yeeyay.git"
set :user , "hariis"
#set :branch, "railsrumble"

role :app, "209.20.69.173"
role :web, "209.20.69.173"
role :db,  "209.20.69.173", :primary => true

set :deploy_to, "/var/www/apps/#{application}"
set :scm, :git
set :branch, "master"

namespace :deploy do
   desc "restart passenger"
   task :restart , :roles => :app, :except => {:no_release => true} do
     run "touch #{current_path}/tmp/restart.txt"
   end
   
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with passenger"
    task t, :roles => :app do ; end
  end
  
  task :after_sysmlink do
    %w[database.yml].each do |c|
        run "ln -nsf #{shared_path}/system/config/#{c} #{current_path}/config/#{c}"
    end
  end
  
  after "deploy:symlink", "deploy:update_crontab"


  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end

end
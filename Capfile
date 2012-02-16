load 'deploy' if respond_to?(:namespace)
load 'deploy/assets'

require 'bundler/capistrano'

Dir['lib/recipes/*.cap'].each { |recipe| load(recipe) }

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ruby-1.9.3-p0'        # Or whatever env you want it to run in.

set :repository,  "git@bitbucket.org:dmitryso/boxx.git"
set :deploy_via, :checkout # remote_cache | checkout | export
set :scm, :git
set :user, "apprunner"
set :password, ENV["ABOX_PWD"]
set :git_enable_submodules, true
set :keep_releases, 3
set :sudo, 'rvmsudo'
set :use_sudo, false
set :rails_env, :production
set :sudo_prompt, "xxxx"
set :bundle_without, [:development, :test]
set :shared_children, fetch(:shared_children) + %w(data)
set :public_children, []
set :project, "rabotnegi"
set :application, "rabotnegi"
set :domain, "rabotnegi.ru"
set :host, "www.rabotnegi.ru"
set :deploy_to, "/app/#{application}"
set :git_host, "bitbucket.org"
set :git_key, "/users/dima/.ssh/id_main"

server host, :web, :app, :db, :primary => true

set :default_environment, { RUBYOPT: "-Ku" }
# set :ssh_options, {keys: ["#{ENV['HOME']}/.ssh/id_rsa"]}
default_run_options[:pty] = true # required for the first time repo access to answer "yes"

set :passenger_config_path, "/etc/apache2/sites-available/#{application}"
set :logrotate_config_path, "/etc/logrotate.d/#{application}"
set :nginx_config_path, "/opt/nginx/conf/sites/#{application}"
set :cron_config_path, "/etc/cron.d/#{application}"
set :base_path, "/data"
set :backups_path, "/data/backup"
set :backups_bucket, "rabotnegi_backups"
set :logs_path, "/data/log"
set :tmp_path, "/data/tmp"
set :app_log_path, "#{logs_path}/#{project}.log"
set :database, "rabotnegi_prod"
set :local_database, "rabotnegi_dev"
set :collections_to_restore, "vacancies"
set :admin_email, "dsokurenko@gmail.com"

# deploy
#   update
#     update_code
#       strategy.deploy!
#       deploy:assets:symlink
#       finalize_update (symlink shared log/pid/system dirs)
        after "deploy:finalize_update", "deploy:update_custom_symlinks"
#       bundle:install
#     deploy:assets:precompile
#     symlink
#   restart
after "deploy", "crontab:install"
after "deploy", "resque:restart"

cron :runner, "15,30,45", "Tasks.kill_spam"
cron :runner, "30 5", "Rabotaru.start_job"
cron :runner, "0 3", "Vacancy.cleanup"
cron :rake, "0 4,16", "data:dump DB=#{database} DIR=#{backups_path} BUCKET=#{backups_bucket}"
cron :rake, "*/10", "cron:ping"

task :demo do
  run "whoami"
  run "ruby -v"
  run "echo $PATH"
  run "echo $USED_CONFIG_FILES"

  sudo "whoami"
  sudo "ruby -v"
  sudo "echo $PATH"
  sudo "echo $USED_CONFIG_FILES"
end
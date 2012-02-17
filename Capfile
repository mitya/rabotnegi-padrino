load 'deploy' if respond_to?(:namespace)
load 'deploy/assets'

require 'bundler/capistrano'

Dir['lib/recipes/*.cap'].each { |recipe| load(recipe) }

set :repository,  "git@bitbucket.org:dmitryso/boxx.git"
set :deploy_via, :remote_cache # remote_cache | checkout
set :scm, :git
set :user, "apprunner"
set :password, ENV["ABOX_PWD"]
set :git_enable_submodules, true
set :keep_releases, 3
set :sudo, 'sudo'
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

# set :default_environment, { RUBYOPT: "-Ku" }
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

cron "15,30,45", "vacancies:kill_spam"
cron "0 3",      "vacancies:cleanup"
cron "30 5",     "rabotaru:start_job"
cron "0 4,16",   "data:dump DB=#{database} DIR=#{backups_path} BUCKET=#{backups_bucket}"
cron "*/5",      "cron:ping"

task :demo do
end

load 'deploy' if respond_to?(:namespace)
load 'deploy/assets'
require 'bundler/capistrano'
require "active_support/core_ext/string"

Dir['vendor/plugins/*/recipes/*.rb', 'lib/recipes/*.rb'].each { |recipe| load(recipe) }

secrets = YAML.load_file("config/secrets.yml")

set :repository,  "git@sokurenko.unfuddle.com:sokurenko/rabotnegi.git"
set :deploy_via, :remote_cache
set :scm, :git
set :user, "apprunner"
set :password, secrets["password"]
set :git_enable_submodules, true
set :keep_releases, 3
set :use_sudo, false
set :rails_env, :production
set :sudo_prompt, "xxxx"
set :bundle_without, [:development, :test, :testui]
set :shared_children, fetch(:shared_children) + %w(data)
set :public_children, []
set :project, "rabotnegi"
set :application, "rabotnegi"
set :domain, "rabotnegi.ru"
set :host, "www.rabotnegi.ru"
set :deploy_to, "/app/#{application}"

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
end

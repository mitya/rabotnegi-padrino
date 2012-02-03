require File.dirname(__FILE__) + '/config/boot.rb'
require 'thor'
require 'padrino-core/cli/rake'

PadrinoTasks.init

# require 'pp'
# require 'resque/tasks'
require 'rake/sprocketstask'

namespace :data do
  # prod: rake data:dump DB=rabotnegi_prod DIR=/data/backup BUCKET=rabotnegi_backups
  # dev: rake data:dump DB=rabotnegi_dev DIR=tmp BUCKET=rabotnegi_backups
  # scp rba:/data/backup/rabotnegi_prod-latest.tbz ~/desktop
  task :dump do
    db, dir, bucket = ENV.values_at('DB', 'DIR', 'BUCKET')
    id = Time.now.strftime("%Y%m%d_%H%M%S")
    name = "#{db}-#{id}"
    
    sh "mongodump -d #{db} -o tmp/#{name}"
    sh "tar -C tmp -cj #{name} > #{dir}/#{name}.tbz"
    sh "rm -rf tmp/#{name} #{dir}/#{db}-latest.tbz"
    sh "ln -s #{name}.tbz #{dir}/#{db}-latest.tbz"
    
    if bucket.present?
      if `which gsutil`.present?
        sh "gsutil cp #{dir}/#{name}.tbz gs://#{bucket}"
      else
        raise "Boto is not there" unless File.exist?("/data/etc/boto.conf")
        raise "GSUtil is not there" unless File.exist?("/data/gsutil/gsutil")
        
        sh "env BOTO_CONFIG=/data/etc/boto.conf /data/gsutil/gsutil cp #{dir}/#{name}.tbz gs://#{bucket}"
      end
    end    
  end
  
  # rake data:upload FILE=/u/backup/dump-20120101-120000.tbz BUCKET=/rabotnegi-backup  
  task :upload do
    file, bucket = ENV.values_at['FILE', 'BUCKET']
    sh "BOTO_CONFIG=/data/etc/boto.conf /data/gsutil/gsutil cp #{file} gs://#{bucket}"
  end
  
  task :clone do
    source = "rabotnegi_dev"
    target = "rabotnegi_testprod"
    sh "rm -rf tmp/dbclone/#{source}"
    sh "mongodump -d #{source} -o tmp/dbclone"
    sh "mongorestore -d #{target} --drop tmp/dbclone/#{source}"
    sh "rm -rf tmp/dbclone/#{source}"
  end
  
  task :restore do
    sh "mongorestore -d rabotnegi_dev --drop #{ENV['SRC']}"
  end  

  # rake data:seed SET=testui
  # rails runner -e testui test/fixtures/data.rb
  task :seed => :environment do
    dataset_name = ENV['SET']
    file = case dataset_name
      when 'testui' then "test/fixtures/data.rb"
    end
    [Vacancy, User, Gore::EventLog::Item].each(&:delete_all)
    load(file)
    puts "Seeded #{Gore.env} - #{{vacancies: Vacancy.count, users: User.count}.inspect}"
  end  

end

namespace :dev do
  task :rm do
    system "rm -rf #{Gore.root}/public/javascripts/pack"
    system "rm -rf #{Gore.root}/public/stylesheets/pack"
    system "rm -rf #{Gore.root}/tmp/cache/*"
    system "rm -rf #{Gore.root}/public/vacancies"
  end  
end

namespace :cron do
  task :ping => :environment  do
    Log.info "Cron ping: event.count=#{Gore::EventLog::Item.count}"
    Resque.enqueue(MiscWorker)
  end
end

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

task "jobs:work" => "resque:work"

Rake::SprocketsTask.new do |t|
  t.environment = Rabotnegi.assets
  t.output = "./public/rabotnegi/assets"
  t.assets = %w( vendor.js bundle.js bundle.css )
end

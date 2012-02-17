require File.dirname(__FILE__) + '/config/boot.rb'
require 'thor'
require 'padrino-core/cli/rake'

PadrinoTasks.init

require 'resque/tasks'
require 'rake/sprocketstask'

namespace :data do
  # prod: rake data:dump DB=rabotnegi_prod DIR=/data/backup BUCKET=rabotnegi_backups
  # dev:  rake data:dump DB=rabotnegi_dev DIR=tmp BUCKET=rabotnegi_backups
  #       scp rba:/data/backup/rabotnegi_prod-latest.tbz ~/desktop
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
  
  # eg. rake data:upload FILE=/u/backup/dump-20120101-120000.tbz BUCKET=/rabotnegi-backup  
  task :upload do
    file, bucket = ENV.values_at['FILE', 'BUCKET']
    sh "BOTO_CONFIG=/data/etc/boto.conf /data/gsutil/gsutil cp #{file} gs://#{bucket}"
  end

  task :clone do
    source, target = ENV.values_at('SRC', 'DST')
    sh "rm -rf tmp/#{source}"
    sh "mongodump -d #{source} -o tmp"
    sh "mongorestore -d #{target} --drop tmp/#{source}"
    sh "rm -rf tmp/#{source}"
  end
end

namespace :dev do
  task :restore do
    src = ENV['SRC'] || "tmp/db.rabotnegi.dev"
    sh "mongorestore -d rabotnegi_dev --drop #{src}"
  end  
  
  task :rm do
    targets = %w(/public/rabotnegi/assets/* /tmp/cache/*).map { |f| Gore.root.join(f) }
    system "rm -rf #{targets.join(' ')}"
  end  
end

task "cron:ping" => :environment do
  Padrino.logger.info "Cron ping: event.count=#{Gore::EventLog::Item.count}"
  Gore.enqueue Gore::Debug, :say, "Resque ping (scheduled at #{Time.now})"
end

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

Rake::SprocketsTask.new do |t|
  t.environment = Rabotnegi.assets
  t.output = "./public/rabotnegi/assets"
  t.assets = %w( vendor.js application.js application.css admin.js admin.css ) + Dir.glob(Padrino.root("app/assets/images/*")).map { |path| path.gsub("#{Padrino.root}/app/assets/images/", '') }
end

task "assets:precompile" => "assets" do
  `cp app/assets/images/* public/rabotnegi/assets`
end

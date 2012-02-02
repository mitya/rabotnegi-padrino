# require "shellwords"
# 
# namespace :app do
#   task :load_demo_data do
#     Gore.env = 'test'
#     Rake::Task['environment'].invoke
# 
#     puts "Loading 100 vacancies into the `#{Gore.env}` database" 
#     100.times { Vacancy.create title: "Test", description: "Hello", industry: "it", city: "msk" }
#   end
# 
#   task(:load => :environment) { Rabotaru.start_job }
# end
# 
# namespace :rabotaru do
#   # usage: rake rabotaru:load CITY=spb,msk INDUSTRY=telework
#   task :load => :environment do
#     $log_to_stdout = true
# 
#     options = {}
#     options[:cities] = ENV['CITY'].split(',').pluck(:to_sym) if ENV['CITY'].present?
#     options[:industries] = ENV['INDUSTRY'].split(',').pluck(:to_sym) if ENV['INDUSTRY'].present?
# 
#     Rabotaru.start_job(options)
#   end
# 
#   task :reload => :environment do
#     $log_to_stdout = true
#     Rabotaru::Job.asc(:created_at).last.try(:rerun)
#   end
# end
#   
# namespace :vacancies do
#   task :count => :environment do
#     puts Vacancy.count
#   end
# 
#   task kill_spam: :environment do
#     Tasks.kill_spam
#   end    
#   
#   task sanitize: :environment do
#     Vacancy.all.each do |v|
#       sanitizer = HTML::FullSanitizer.new
#       v.title = sanitizer.sanitize(v.title)
#       v.employer_name = sanitizer.sanitize(v.employer_name)
#       v.save!
#     end    
#   end
#   
#   task clean: :environment do
#     since = Time.parse ENV['SINCE']
#     puts "Cleaning vacancies since #{since}"
#     VacancyCleaner.clean_all since
#   end
# end  

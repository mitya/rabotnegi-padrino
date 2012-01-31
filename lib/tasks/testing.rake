# namespace :test do
#   task :ui do
#     sh "rake test:ui_internal X_RAILS_ENV=testui"
#   end
# 
#   Rake::TestTask.new(:ui_internal) do |t|
#     t.libs << "test"
#     t.pattern = 'test/ui/**/*_test.rb'
#     t.verbose = true
#     t.options = "--verbose=verbose"
#   end
#   
#   task :ui_seed do
#     sh "rake data:seed[testui] RAILS_ENV=testui"
#   end
#   
#   Rails::SubTestTask.new(:plumbing) do |t|
#     t.libs << "test"
#     t.pattern = 'test/plumbing/**/*_test.rb'
#   end  
#   
#   Rails::SubTestTask.new(:all) do |t|
#     t.libs << "test"
#     t.test_files = FileList[
#       'test/unit/**/*_test.rb',
#       'test/plumbing/**/*_test.rb', 
#       'test/functionals/**/*_test.rb',
#       'test/integration/**/*_test.rb',
#       'test/helpers/**/*_test.rb',
#     ]
#   end
#   
#   task :default => "test:all"
# end
# 
# Rake::Task['test'].clear
# task :test => "test:all"

require 'rake/testtask'

namespace :test do
  %w(lib rabotnegi/unit rabotnegi/functional).each do |folder|
    Rake::TestTask.new("#{folder.gsub('/', ':')}") do |test|
      test.libs << "test"
      test.pattern = "test/#{folder}/**/*_test.rb"
      test.verbose = true
    end
  end

  Rake::TestTask.new("all") do |test|
    test.libs << "test"
    test.test_files = FileList[
      'test/rabotnegi/unit/**/*_test.rb',
      'test/rabotnegi/functional/**/*_test.rb',
      'test/lib/**/*_test.rb', 
    ]  
    test.verbose = true
  end

  Rake::TestTask.new("ui") do |t|
    t.libs << "test"
    t.pattern = 'test/rabotnegi/ui/**/*_test.rb'
    t.verbose = true
  end
  
  task "unit" => "test:rabotnegi:unit"
  task "func" => "test:rabotnegi:functional"  
end

task "test" => "test:all"

require 'rake/testtask'

test_folders = %w(lib rabotnegi/unit rabotnegi/functional)
test_folders.each do |folder|
  Rake::TestTask.new("test:#{folder.gsub('/', ':')}") do |test|
    test.libs << "test"
    test.pattern = "test/#{folder}/**/*_test.rb"
    test.verbose = true
  end
end

Rake::TestTask.new("test") do |test|
  test.libs << "test"
  test.test_files = FileList[
    'test/rabotnegi/unit/**/*_test.rb',
    'test/rabotnegi/functional/**/*_test.rb',
    'test/lib/**/*_test.rb', 
  ]  
  test.verbose = true
end

task "test:unit" => "test:rabotnegi:unit"
task "test:func" => "test:rabotnegi:web"

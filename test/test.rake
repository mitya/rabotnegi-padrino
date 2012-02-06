require 'rake/testtask'

test_folders = %w(plumbing rabotnegi/unit rabotnegi/web)
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
    'test/rabotnegi/web/**/*_test.rb',
    'test/plumbing/**/*_test.rb', 
  ]  
  test.verbose = true
end

task "test:unit" => "test:rabotnegi:unit"
task "test:web" => "test:rabotnegi:web"

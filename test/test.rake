require 'rake/testtask'

test_folders = %w(plumbing rabotnegi/unit rabotnegi/functional)
test_folders.each do |folder|
  Rake::TestTask.new("test:#{folder.gsub('/', ':')}") do |test|
    test.libs << "test"
    test.pattern = "test/#{folder}/**/*_test.rb"
    test.verbose = true
  end
end

desc "Run application test suite"
task 'test' => test_folders.map { |f| "test:#{f.gsub('/', ':')}" }

task "test:unit" => "test:rabotnegi:unit"
#!/usr/bin/env ruby

require 'pp'
# require 'daemons'
# require 'optparse'
# 
rails_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
ENV['RAILS_PROC'] = 'worker-rr'
# 
# id = ARGV.shift
# raise("Numeric ID should be given as the first argument") unless id.to_i > 0
# 
# Daemons.run_proc("resque.#{id}", dir: File.join(rails_root, "tmp/pids"), dir_mode: :normal, log_output: true, log_dir: File.join(rails_root, "log")) do
#   Dir.chdir(rails_root)
#   require File.join(rails_root, "config/environment")
#   worker = Resque::Worker.new("*")
#   worker.verbose = true
#   worker.work(5)
# end

require File.join(rails_root, "config/environment")
Rabotaru.start_job

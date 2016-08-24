#!/usr/bin/env ruby
# -*- ruby -*-

# @author Mathias Bayon

require 'rake'
require 'rspec/core/rake_task'

require_relative 'MBA_steganography'

task :default => :run

task :run do
    ruby "ruby MBA_steganography.rb"
end

task :spec do
    puts "Runnign RSpec task..."
    RSpec::Core::RakeTask.new(:spec)
end

task :clean do
    File.delete(*Dir.glob('./*.log*'))
end

#!/usr/bin/env ruby

require "rubygems"
require "rake"

# Ensure project root is in the LOAD_PATH
$LOAD_PATH.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "lib"))

ProjectRoot = File.dirname(File.expand_path(__FILE__))

# Set Flags
$Flags = {} if $Flags.nil?
if Rake.application.options.trace
  $Flags[:verbose] = true
end

# Load all Rake Task definitions
Dir["#{ProjectRoot}/rake/*.rake"].each do |file|
  puts "Loading #{File.basename(file)}" if Rake.application.options.trace
  load file
end

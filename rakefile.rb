#!/usr/bin/env ruby

require "rubygems" if RUBY_VERSION.match(/1.8/)
require "rake"

# Ensure project root is in the LOAD_PATH
$LOAD_PATH.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"lib"))

# Set Flags
$Flags = {} if $Flags.nil?
if Rake.application.options.trace
  $Flags[:verbose] = true
end

# Load RailsInstaller
require "railsinstaller"

# Load all Rake Task definitions
Dir["#{RailsInstaller::Root}/rake/*.rake"].each do |rakefile|
  load rakefile
end

#!/usr/bin/env ruby

# Ensure project root is in the LOAD_PATH
$LOAD_PATH.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"lib"))

require "rubygems" if RUBY_VERSION.match(/1.8/)

require "rake"

if Rake.application.options.trace
  $Flags ||= Hash.new
  $Flags[:verbose] = true
end

# Load RailsInstaller
require "railsinstaller"

# Load all Rake Task definitions
Dir["#{RailsInstaller::Root}/rake/*.rake"].each do |rakefile|
  require rakefile
end

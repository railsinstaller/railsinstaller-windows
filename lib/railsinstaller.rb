module RailsInstaller # Ensure that the RailsInstaller project root is defined.
  Root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
end

%w[ rubygems ostruct yaml erb uri ].each do |name|
  printf "Loading #{name}...\n" if $Flags[:verbose]
  require name
end

%w[ globals ].each do |name|
  printf "Loading #{name}...\n" if $Flags[:verbose]
  require File.expand_path(File.join(RailsInstaller::Root,"lib", "setup", name +'.rb'))
end

%w[ stdlib ].each do |name|
  printf "Loading #{name}...\n" if $Flags[:verbose]
  require File.expand_path(File.join(RailsInstaller::Root,"lib", "extensions", name +'.rb'))
end

%w[ components behavior utilities downloads actions ].each do |name|
  printf "Loading #{name}...\n" if $Flags[:verbose]
  require File.expand_path(File.join(RailsInstaller::Root,"lib", "railsinstaller", name +'.rb'))
end

module RailsInstaller
  extend RailsInstaller::Utilities
  extend RailsInstaller::Downloads
end

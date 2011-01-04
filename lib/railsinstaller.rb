
module RailsInstaller # Ensure that the RailsInstaller project root is defined.
  Root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
end

%w{
  rubygems
  ostruct
  yaml
  erb
  extensions/stdlib
  railsinstaller/methods
  railsinstaller/base
  railsinstaller/behavior
  railsinstaller/download
  railsinstaller/utilities
}.each do |name|

  printf "Loading #{name}...\n" if $Flags[:verbose]

  require name

end


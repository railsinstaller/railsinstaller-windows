
module RailsInstaller # Ensure that the RailsInstaller project root is defined.
  Root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
end

%w{
  ostruct
  yaml
  erb
  net/http
  uri
  extensions/stdlib
  railsinstaller/methods
  railsinstaller/base
  railsinstaller/behavior
}.each do |name|

  printf "Loading #{name}...\n" if $Flags[:verbose]

  require name

end


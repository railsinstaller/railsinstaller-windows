# Load standard libraries that are used.
require "ostruct"
require "yaml"
require "erb"

# Ensure that the RailsInstaller project root is defined.
module RailsInstaller
  Root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
end

# Load extensions to standard libraries that are used in RailsInstaller
require "extensions/stdlib"

# Load all RailsInstaller libraries
for name in [ "helpers", "utilities", "components", "compilers" ]

  printf "Loading RailsInstaller #{name}...\n" if $Flags[:verbose]
  require "railsinstaller/#{name}"

end

task :default do
  printf "\nRailsInstaller Rake Tasks:

  {bootstrap, build, package}

See README.md for more details.\n\n"
end

task :require_railsinstaller do

  require "railsinstaller"

end

desc "Download SSL certificate for HTTPS resources"
task :ssl_cert do
  require 'net/http'

  # create a path to the file "C:\RailsInstaller\cacert.pem"
  cacert_file = File.join(ProjectRoot, "stage", "cacert.pem")
   
  Net::HTTP.start("curl.haxx.se") do |http|
    resp = http.get("/ca/cacert.pem")
    if resp.code == "200"
      open(cacert_file, "wb") { |file| file.write(resp.body) }
      puts "\n\nA bundle of certificate authorities has been installed to"
      puts "#{cacert_file}\n"
      puts "* Please set SSL_CERT_FILE in your current command prompt session with:"
      puts "     set SSL_CERT_FILE=#{cacert_file}"
      puts "* To make this a permanent setting, add it to Environment Variables"
      puts "  under Control Panel -> Advanced -> Environment Variables"
    else
      abort "\n\n>>>> A cacert.pem bundle could not be downloaded."
    end
  end
end

desc "Bootstrap RailsInstaller development environment (gems)"
task :bootstrap do

  require "rubygems/dependency_installer"

  gems = File.read(File.join(ProjectRoot, ".gems")).gsub(" -v", ' ').split("\n")

  gems.each do |gem|

    printf "Ensuring #{gem} is installed...\n"

    name, version, options = gem.split(/\s+/)

    installer = Gem::DependencyInstaller.new(
      { :generate_rdoc => false, :generate_ri => false }
    )

    version ? installer.install(name, version) : installer.install(name)

  end

  printf "Bootstrapped.\nDo not forget to download and install Inno Setup, see README.md for more information.\n"

end

desc "Download and build all components and dependencies into stage/."
task :build => [ :require_railsinstaller ] do

  RailsInstaller.build!

end

desc "Package all components into a single executable installer into pkg/."
task :package => [ :require_railsinstaller ] do

  RailsInstaller.package!

end

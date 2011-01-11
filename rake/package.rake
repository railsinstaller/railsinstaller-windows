namespace :railsinstaller do

  desc "Package all RailsInstaller components into a single executable installer."
  task :package do
    RailsInstaller.package!
  end

end

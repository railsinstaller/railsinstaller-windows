namespace :railsinstaller do

  desc "Build all RailsInstaller components and dependencies."
  task :build do

    RailsInstaller.build!

  end

end

namespace :railsinstaller do

  desc "Build all RailsInstaller components and dependencies."
  task :build do

    include RailsInstaller::Utilities

    #
    # Configuration / Variables
    #
    stage_path="#{RailsInstaller::Root}/stage"
    gems = %q(rake rails mysql pg)

    #
    # RubyInstaller
    #
    url = RailsInstaller::Components::RubyInstaller.url
    filename = "#{stage_path}/#{File.basename(url)}"

    download(url, filename) and extract(filename)

    #
    # DevKit
    #
    log "Building DevKit using RubyInstaller."

    sh(%Q{cd "#{stage_path}/railsinstaller" && "rake devkit 7Z=1"})

    log "Extracting DevKit into the staging directory."

    # extract devkit and run the rake tasks to link with ruby
    # TODO: Ask Luis the best way to go about this.

    log "Linking DevKit with Ruby installed on the stage."
    # TODO: Ask Luis the best way to go about this.

    #
    # Gems
    #
    gems.each do |gemname|
      build_gem(gemname)
    end

    #
    # Git
    #
    url = RailsInstaller::Components::Git.url
    filename = RailsInstaller::Components::Git.filename

    download(url, filename) and extract(filename)

  end

end

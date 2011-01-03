namespace :railsinstaller do

  desc "Build all RailsInstaller components and dependencies."
  task :build do

    include RailsInstaller::Utilities

    #
    # Configuration / Variables
    #
    stage_path="#{RailsInstaller::Root}/stage"

    #
    section "RubyInstaller"
    #
    printf %Q{#\n# RubyInstaller\n#\n}
    url = RubyInstaller.url
    filename = "#{stage_path}/#{File.basename(url)}"

    download(url, filename) and extract(filename)

    #
    section "DevKit"
    #
    download(DevKit.url, DevKit.filename) and extract(DevKit.filename)

    DevKit.init_ruby("#{stage_path}\\DevKit",
                     "#{stage_path}\\rubyinstaller\\Ruby187\\bin")

    #
    section "Gems"
    #
    build_gems(%q(rake rails mysql pg))

    #
    # Git
    #
    download(Git.url, Git.filename) and extract(Git.filename)

  end

end

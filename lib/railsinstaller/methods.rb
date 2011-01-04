module RailsInstaller

  def self.build!

    #
    # Configuration / Variables
    #
    stage_path="#{RailsInstaller::Root}\\stage"

    #
    section "RubyInstaller"
    #
    url = RubyInstaller.versions["1.8.7-p330"]
    filename = "#{stage_path}/#{File.basename(url)}"

    download(url, filename) and extract(filename)

    #
    section "DevKit"
    #
    url = DevKit.url
    filename = File.basename(url)
    download(url, filename) and extract(filename)

    init_devkit_ruby("#{stage_path}\\DevKit",
                     "#{stage_path}\\rubyinstaller\\Ruby187\\bin")

    #
    section "Gems"
    #
    build_gems(%w(rake rails mysql pg))

    #
    # Git
    #
    download(Git.url, Git.filename) and extract(Git.filename)

  end

end

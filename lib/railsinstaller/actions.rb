module RailsInstaller

  def self.build!
    section "Utilities"

    install_utility(RailsInstaller::SevenZip.url, "7za.exe")

    install_utility(RailsInstaller::BSDTar.url, "basic-bsdtar.exe")

    section "RubyInstaller"

    url = RubyInstaller.versions["1.8.7-p330"][:url]
    filename = File.join(RailsInstaller::Stage, File.basename(url))
    rubyname = RubyInstaller.versions["1.8.7-p330"][:name]
    ruby_path = File.join(RailsInstaller::Stage, rubyname)
    devkit_path = File.join(RailsInstaller::Stage, "DevKit")

    FileUtils.rm_rf(ruby_path) if Dir.exists?(ruby_path)

    download(url, RailsInstaller::Stage)

    extract(filename, {:force => true})

    section "DevKit"
    url = DevKit.url
    filename = File.join(RailsInstaller::Stage, File.basename(url))

    download(url, RailsInstaller::Stage)

    FileUtils.rm_rf(devkit_path) if Dir.exists?(devkit_path)

    extract(filename, {:target_path => devkit_path, :extract => true})

    install_devkit_into_ruby( devkit_path, File.join(ruby_path, "bin") )

    # PostgreSQL will be part of Phase II
    # section "PostgreSQL Server"
    # download(PostgreSQLServer.url, PostgreSQLServer.filename) and extract(PostgreSQLServer.filename)

    # MySQL will be part of Phase II
    # section "MySQL Server"
    # download(MySQLServer.url, MySQLServer.filename) and extract(MySQLServer.filename)

    section "Gems"
    # The pg and mysql gems Will be part of Phase II
    gems = %w(rake rails json sqlite-ruby)
    build_gems(gems)

    section "Git"
    download(Git.url, Git.filename) and extract(Git.filename)
  end

end

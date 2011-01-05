module RailsInstaller

  def self.build!
    section "Utilities"

    install_utility(RailsInstaller::SevenZip.url, "7za.exe")

    install_utility(RailsInstaller::BSDTar.url, "basic-bsdtar.exe")

    section "RubyInstaller"

    url = RubyInstaller.versions["1.8.7-p330"]
    filename = File.join(RailsInstaller::Stage, File.basename(url))

    download(url, filename) and extract(filename)

    section "DevKit"
    url = DevKit.url
    filename = File.basename(url)
    download(url, filename) and extract(filename)
    install_devkit_into_ruby(
      File.join(RailsInstaller::Stage, File.dirname(filename)),
      File.join(RailsInstaller::Stage, "rubyinstaller", "Ruby187", "bin")
    )

    section "PostgreSQL Server"
    download(PostgreSQLServer.url, PostgreSQLServer.filename) and extract(PostgreSQLServer.filename)

    section "MySQL Server"
    download(MySQLServer.url, MySQLServer.filename) and extract(MySQLServer.filename)

    section "Gems"
    build_gems(%w(rake rails mysql pg))

    section "Git"
    download(Git.url, Git.filename) and extract(Git.filename)
  end

end

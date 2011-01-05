module RailsInstaller

  def self.build!
    # Configuration / Variables
    bsdtar_install

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

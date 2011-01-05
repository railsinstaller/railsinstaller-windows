module RailsInstaller

  def self.build!
    # Configuration / Variables
    stage_path = File.join(RailsInstaller::Root, "stage")

    section "RubyInstaller"
    url = RubyInstaller.versions["1.8.7-p330"]
    filename = File.join(stage_path, File.basename(url))

    download(url, filename) and extract(filename)

    section "DevKit"
    url = DevKit.url
    filename = File.basename(url)
    download(url, filename) and extract(filename)

    init_devkit_ruby(
      File.join(stage_path, DevKit),
      File.join(stage_path, "rubyinstaller", "Ruby187", "bin")
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

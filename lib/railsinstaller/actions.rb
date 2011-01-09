module RailsInstaller

  def self.build!

    section "Utilities"

    components = [ BSDTar, SevenZip, DevKit, Git, PostgreSQLServer, Sqlite3 ]

    components.each do |package|
      section  package.name # TODO: Add package.description to the yml file.
      download package
      extract  package
    end

    section  "RubyInstaller"
    url       = RubyInstaller.versions["1.8.7-p330"][:url]
    filename  = File.basename(url)
    rubyname  = RubyInstaller.versions["1.8.7-p330"][:name]
    ruby_path = File.join(RailsInstaller::Stage, rubyname)

    FileUtils.rm_rf(ruby_path) if File.directory?(ruby_path)
    download(DevKit)
    extract(DevKit)

    %w(sqlite3.dll sqlite3.exe).each do |file|
      FileUtils.mv(
        File.join(RailsInstaller::Stage, file),
        File.join(ruby_path, "bin", file)
      )
    end

    section "Gems"

    gems = %w(rake rails json sqlite3-ruby)

    build_gems(ruby_path, gems)

    build_gem(ruby_path, "pg", {
      :args => "-- --with-pg-include=#{File.join(RailsInstaller::Stage, "pgsql", "include")} --with-pg-lib=#{File.join(RailsInstaller::Stage, "pgsql", "lib")}"
    })

  end

end

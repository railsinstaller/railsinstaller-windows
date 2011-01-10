module RailsInstaller

  def self.build!

    components = [ BSDTar, SevenZip, DevKit, Git, RubyInstaller, PostgreSQLServer, Sqlite3, Sqlite3Dll ]

    components.each do |package|
      section  package.name # TODO: Add package.description to the yml file.
      download package
      extract  package
    end

    # TODO: Make sure that sqlite is getting to the ruby bin dir on stage.
    %w(sqlite3.dll sqlite3.def sqlite3.exe).each do |file|
      FileUtils.mv(
        File.join(RailsInstaller::Stage, file),
        File.join(RailsInstaller::Stage, RubyInstaller.rename, "bin", file)
      ) if File.exist?(File.join(RailsInstaller::Stage, file))
    end

    link_devkit_with_ruby(
      File.join(RailsInstaller::Stage, DevKit.target),
      File.join(RailsInstaller::Stage, RubyInstaller.rename)
    )

    section "Gems"

    gems = %w(rake rails json sqlite3-ruby)

    build_gems(File.join(RailsInstaller::Stage, RubyInstaller.rename), gems)

    build_gem(File.join(RailsInstaller::Stage, RubyInstaller.rename), "pg", {
      :args => [
          "--",
          "--with-pg-include=#{File.join(RailsInstaller::Stage, "pgsql", "include")}",
          "--with-pg-lib=#{File.join(RailsInstaller::Stage, "pgsql", "lib")}"
      ].join(' ')
    })

  end

end

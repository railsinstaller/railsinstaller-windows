module RailsInstaller

  def self.build!

    components = [ BSDTar, SevenZip, DevKit, Git, Ruby187, PostgresServer, Sqlite3, Sqlite3Dll ]

    components.each do |package|
      section  package.name # TODO: Add package.description to the yml file.
      download package
      extract  package
    end

    # TODO: Make sure that sqlite is getting to the ruby bin dir on stage.
    %w(sqlite3.dll sqlite3.def sqlite3.exe).each do |file|
      FileUtils.mv(
        File.join(Stage, file),
        File.join(Stage, Ruby187.rename, "bin", file)
      ) if File.exist?(File.join(Stage, file))
    end

    link_devkit_with_ruby(
      File.join(Stage, DevKit.target),
      File.join(Stage, Ruby187.rename)
    )

    # TODO: Extract this into a function call that operations on the package object.
    %w( libpq.dll ssleay32.dll, libeay32.dll, libintl-8.dll msvcr90.dll libxml2.dll ).each do |file|
    FileUtils.cp(
        File.join(Stage, PostgresServer.target, "bin", file),
        File.join(Stage, Ruby187.rename, "bin", file)
    ) if File.exist?(File.join(Stage, file))
    end

    section "Gems"

    gems = %w( rake rails json sqlite3-ruby )

    build_gems(File.join(Stage, Ruby187.rename), gems)

    build_gem(File.join(Stage, Ruby187.rename), "pg", {
      :args => [
          "--",
          "--with-pg-include=#{File.join(Stage, "pgsql", "include")}",
          "--with-pg-lib=#{File.join(Stage, "pgsql", "lib")}"
      ].join(' ')
    })


    ruby_binary("rails", "new", "sample", File.join(Stage, Ruby187.rename))

    # MSVC Runtime 2008
    # download(MsvcRuntime.url)

    # FileUtils.mv(
    #   File.join(RailsInstaller::Archives, File.basename(MsvcRuntime.url)),
    #   File.join(RailsInstaller::Stage, File.basename(MsvcRuntime.url))
    # )

  end

  #
  # package()
  #
  # Packages a binary installer release version together as a
  # self contained installer using Inno Setup scripting.
  #
  def self.package!
    version = File.read(File.join(RailsInstaller::Root, "VERSION")).chomp

    printf "Packaging... this *will* take a while...\n"

    iscc "\"#{File.join(RailsInstaller::Root, "resources", "railsinstaller", "railsinstaller.iss")}\"",
          "/dInstallerVersion=#{version}",
          "/dStagePath=\"#{RailsInstaller::Stage}\"",
          "/dRubyPath=\"#{RailsInstaller::Ruby187.rename}\"",
          "/dRailsPath=\"#{File.join(RailsInstaller::Root, "Rails")}\"",
          "/o\"#{RailsInstaller::PackageDir}\"",
          "/frailsinstaller-#{version}"

  end

end

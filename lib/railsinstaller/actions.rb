module RailsInstaller

  def self.build!

    components = [ BSDTar, SevenZip, DevKit, Git, RubyInstaller, PostgresServer, Sqlite3, Sqlite3Dll ]

    components.each do |package|
      section  package.name # TODO: Add package.description to the yml file.
      download package
      extract  package
    end

    # TODO: Make sure that sqlite is getting to the ruby bin dir on stage.
    %w(sqlite3.dll sqlite3.def sqlite3.exe).each do |file|
      FileUtils.mv(
        File.join(Stage, file),
        File.join(Stage, RubyInstaller.rename, "bin", file)
      ) if File.exist?(File.join(Stage, file))
    end

    link_devkit_with_ruby(
      File.join(Stage, DevKit.target),
      File.join(Stage, RubyInstaller.rename)
    )

    # TODO: Extract this into a function call that operations on the package object.
    %w( libpq.dll ssleay32.dll, libeay32.dll, libintl-8.dll msvcr90.dll libxml2.dll ).each do |file|
    FileUtils.cp(
        File.join(Stage, PostgresServer.target, "bin", file),
        File.join(Stage, RubyInstaller.rename, "bin", file)
    ) if File.exist?(File.join(Stage, file))
    end

    section "Gems"

    gems = %w( rake rails json sqlite3-ruby )

    build_gems(File.join(Stage, RubyInstaller.rename), gems)

    build_gem(File.join(Stage, RubyInstaller.rename), "pg", {
      :args => [
          "--",
          "--with-pg-include=#{File.join(Stage, "pgsql", "include")}",
          "--with-pg-lib=#{File.join(Stage, "pgsql", "lib")}"
      ].join(' ')
    })

  end

  #
  # package()
  #
  # Packages a binary installer release version together as a
  # self contained installer using Inno Setup scripting.
  #
  def self.package!
    version = File.read(File.join(RailsInstaller::Root, "VERSION")).chomp

    command = [
      "iscc",
      "\"#{File.join(RailsInstaller::Root, "resources", "railsinstaller", "railsinstaller.iss")}\"",
      "/dInstallerVersion=#{version}",
      "/dStagePath=\"#{RailsInstaller::Stage}\"",
      "/dRubyPath=\"#{RailsInstaller::RubyInstaller.rename}\"",
      "/o\"#{RailsInstaller::PackageDir}\"",
      "/frailsinstaller-#{version}"
    ].join(' ')

    printf "DEBUG: > #{command}\n" if $Flags[:verbose]
    printf "Packaging... this *will* take a while...\n"
    output, error, status = Open3.capture3(command)

    if $Flags[:verbose]
      puts output
      puts error unless error.empty?
    end

  end

end

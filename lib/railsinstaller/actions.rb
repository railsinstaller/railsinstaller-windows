module RailsInstaller

  def self.build!

    components = [ BSDTar, SevenZip, DevKit, Git, Ruby187, PostgresServer, Sqlite3, Sqlite3Dll ]

    components.each do |package|
      section  package.title
      download package
      extract  package
    end

    stage_sqlite

    link_devkit_with_ruby

    stage_git

    stage_postgresql

    stage_gems

    stage_rails_sample_application

    stage_msvc_runtime
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
          "/o\"#{RailsInstaller::PackageDir}\"",
          "/frailsinstaller-#{version}"

  end

end

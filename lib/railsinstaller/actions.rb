module RailsInstaller

  def self.build!

    components = [
      BSDTar, SevenZip, DevKit, Git, Ruby200,
      PostgresServer, Sqlite3, Sqlite3Dll
      #, SSLCertificates
    ]

    components.each do |package|
      section  package.title
      download package
      extract  package
      #unless package.title == "SSLCertificates"
    end

    stage_sqlite

    #stage_certificates

    link_devkit_with_ruby

    stage_git

    stage_postgresql

    stage_gems

    stage_todo_application

    stage_setup_scripts

    stage_msvc_runtime
  end

  #
  # package()
  #
  # Packages a binary installer release version together as a
  # self contained installer using Inno Setup scripting.
  #
  def self.package!

    unless %x{iscc --version}.scan("Inno Setup 5")
      printf "ERROR: Inno Setup is required in order to package RailsInstaller.\n"
      printf "  http://www.jrsoftware.org/isdl.php#qsp\n"
      printf "Please see README.md for full RailsInstaller instructions.\n"
      exit 1
    end

    railsinstaller_version = File.read(File.join(RailsInstaller::Root, "VERSION.txt")).chomp

    printf "\nPackaging... this *will* take a while...\n"

    iscc "\"#{File.join(RailsInstaller::Root, "resources", "railsinstaller", "railsinstaller.iss")}\"",
          "/dInstallerVersion=#{railsinstaller_version}",
          "/dStagePath=\"#{RailsInstaller::Stage}\"",
          "/dRubyPath=\"#{RailsInstaller::Ruby200.rename}\"",
          "/dResourcesPath=\"#{File.join(RailsInstaller::Root, "resources")}\"",
          "/o\"#{RailsInstaller::PackageDir}\"",
          "/frailsinstaller-#{railsinstaller_version}"

  end

end

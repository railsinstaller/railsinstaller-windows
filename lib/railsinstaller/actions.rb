module RailsInstaller

  def self.build!
    section "Utilities"

    install_utility(RailsInstaller::BSDTar.url, "basic-bsdtar.exe")
    $Flags[:bootstrapped] = true

    install_utility(RailsInstaller::SevenZip.url, "7za.exe")

   section  "RubyInstaller"
   url       = RubyInstaller.versions["1.8.7-p330"][:url]
   filename  = File.join(RailsInstaller::Stage, File.basename(url))
   rubyname  = RubyInstaller.versions["1.8.7-p330"][:name]
   ruby_path = File.join(RailsInstaller::Stage, rubyname)

   FileUtils.rm_rf(ruby_path) if Dir.exists?(ruby_path)

   download(url, RailsInstaller::Stage)

   extract(filename, {:force => true})

   section  "DevKit"
   url      = DevKit.url
   filename = File.join(RailsInstaller::Stage, File.basename(url))
   path     = File.join(RailsInstaller::Stage, "DevKit")

   download(url, RailsInstaller::Stage)

   FileUtils.rm_rf(path) if Dir.exists?(path)

   extract(filename, {:target_path => path, :extract => true})

   install_devkit_into_ruby( path, File.join(ruby_path, "bin") )

   section  "Git"
   url      = Git.url
   filename = File.join(RailsInstaller::Stage, File.basename(url))
   path     = File.join(RailsInstaller::Stage, "Git")

   download(url, RailsInstaller::Stage)

   FileUtils.rm_rf(path) if Dir.exists?(path)

   extract(filename, {:target_path => path, :extract => true})

   section "PostgreSQL Server"

   url      = PostgreSQLServer.url
   filename = File.join(RailsInstaller::Stage, File.basename(url))
   path     = RailsInstaller::Stage

   download(url, RailsInstaller::Stage)

   extract(filename) # , {:target_path => path, :extract => true})

   section "Gems"
   gems     = %w(rake rails json sqlite3-ruby)

   build_gems(ruby_path, gems)

   build_gem(ruby_path, "pg",
              {:args => "-- --with-pg-config=#{File.join(RailsInstaller::Stage, "psql", "bin", "pg_config")}"}
   )

  end

end

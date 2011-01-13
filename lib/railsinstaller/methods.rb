module RailsInstaller

  #
  # unzip:
  # Requires: rubyzip2 (gem install rubyzip2) # require "zip/zip"
  #
  def self.unzip(package)

    filename  = File.basename(package.url)
    base_path = File.dirname(filename)
    if package.target.nil?
      target_path = base_path
    else
      target_path = File.join(base_path, package.target)
    end
    regex     = Regexp.new(package.regex) unless package.regex.nil?
    files     = []

    printf " => Extracting #{filename}\n"

    Dir.chdir(RailsInstaller::Archives) do

      Zip::ZipFile.open(File.join(RailsInstaller::Archives, filename)) do |zipfile|

        printf "zipfile: #{zipfile.inspect}\n" if $Flags[:verbose]

        if regex

          entries = zipfile.entries.select do |entry|

            entry.name.match(regex)

          end

        else
          entries = zipfile.entries
        end

        FileUtils.mkdir_p(File.join(RailsInstaller::Stage, "bin"))

        entries.each do |entry|

          printf "DEBUG: Extracting #{entry.name}\n" if $Flags[:verbose]

          files << entry.name

          FileUtils.rm_f(entry.name) if File.exists?(entry.name)

          zipfile.extract(entry, entry.name)

          if File.exist?(File.join(RailsInstaller::Archives, entry.name))
            FileUtils.mv(
              File.join(RailsInstaller::Archives, entry.name),
              File.join(RailsInstaller::Stage, "bin", entry.name),
              :force => true
            )
          end

        end

      end

    end

    files

  end

  #
  # extract
  #
  # Used to extract a non-zip file using BSDTar
  #
  def self.extract(package)

    Dir.chdir(RailsInstaller::Archives) do

      filename = File.basename(package.url)

      unless File.exists?(filename)
        raise "ERROR: #{filename} does not exist, did the download step fail?"
      end

      if package.target.nil?
        target_path = RailsInstaller::Stage
      else
        target_path = File.join(RailsInstaller::Stage, package.target)
      end
      bsdtar      = File.join(RailsInstaller::Stage, "bin", RailsInstaller::BSDTar.binary)
      sevenzip    = File.join(RailsInstaller::Stage, "bin", RailsInstaller::SevenZip.binary)

      if package.type == "utility" && File.exist?(File.join(RailsInstaller::Stage, "bin", package.binary))
        printf "#{package.name} already on stage.\n"
        return
      end

      printf " => Extracting '#{filename}' to the stage.\n" if $Flags[:verbose]

      FileUtils.mkdir_p(RailsInstaller::Stage) unless File.directory?(RailsInstaller::Stage)

      case package.type
        when "utility" # Remove target file, if exists.

          target = File.join(RailsInstaller::Stage, "bin", package.binary)
          if File.exists?(target)
            printf "#{target} on stage.\n"
            return
          end
          FileUtils.rm_f(target) if File.exist?(target)

        when "component" # Remove target dir if it exists and is different than the stage

          if (File.directory?(target_path) && target_path != RailsInstaller::Stage)
            FileUtils.rm_rf(target_path)
          end

        else
        raise "Unknown package type.\npackage type should be one of 'utility' or a 'component'?"
      end

      archive = File.join(RailsInstaller::Archives, filename)

      Dir.chdir(RailsInstaller::Stage) do

          case filename
            when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/, /(^.+\.tar)\.lzma$/, /(^.+)\.tgz$/

            command = %Q("#{bsdtar}" -xf "#{archive}")

            when /^.+\.7z$/

            command = %Q("#{sevenzip}" x -y -t7z -o#{target_path} "#{archive}")

            when /^.+sfx\.exe$/

            command = %Q("#{sevenzip}" x -y -t7z -sfx -o#{target_path} #{archive})

            when /(^.+\.zip$)/

            if File.exist?(sevenzip) # Use bsdtar once we already have it

              command = %Q("#{sevenzip}" x -y -o#{target_path} #{archive})

            else

              return unzip(package) # For the unzip case we can return a list of extracted files.

            end

          else
            raise "\nERROR:\n  Cannot extract #{archive}, unhandled file extension!\n"
        end

        sh(command)

        if package.rename

          case package.type

            when "component"

              Dir.chdir(RailsInstaller::Stage) do

                FileUtils.rm_rf(package.rename) if File.exist?(package.rename)

                source = File.basename(package.url, File.extname(package.url))
                printf "DEBUG: source: %s\ntarget: %s\n", source, package.rename
                FileUtils.mv(
                  File.basename(package.url, File.extname(package.url)),
                  package.rename
                )

              end

          end

        end

      end

    end

  end

  #
  # install_utility()
  #
  # Requires: open-uri
  #
  def self.install_utility

    # TODO: Merge this into download, simply check if object has a .binary attribute.
    if File.exists?(File.join(RailsInstaller::Stage, "bin", binary))

      printf "#{File.join(RailsInstaller::Stage, "bin", binary)} exists.\nSkipping download, extract and install.\n"

    else

      printf " => Downloading and extracting #{binary} from #{utility.url}\n"

      FileUtils.mkdir_p(RailsInstaller::Stage) unless File.directory?(RailsInstaller::Stage)

      Dir.chdir(RailsInstaller::Stage) do

        filename = File.basename(utility.url)

        FileUtils.rm_f(filename) if File.exist?(filename)

        # Utilities are small executables, thus using open-uri to download them is fine.
        open(utility.url) do |temporary_file|

          File.open(filename, "wb") do |file|

            file.write(temporary_file.read)

          end

        end

        extract(binary)

        printf " => Instaling #{binary} to #{File.join(RailsInstaller::Stage, "bin")}\n"

        FileUtils.mkdir_p(RailsInstaller::Stage, "bin") unless File.directory?(RailsInstaller::Stage, "bin")

        FileUtils.mv(
          File.join(RailsInstaller::Stage, binary),
          File.join(RailsInstaller::Stage, "bin", binary),
          :force => true
        )

      end
    end

  end

  #
  # Copy required Sqlite3 files on to the stage
  #
  def self.stage_sqlite

    Sqlite3.files.each do |file|

      if File.exist?(File.join(Stage, file))

        FileUtils.mv(
          File.join(Stage, file),
          File.join(Stage, Ruby187.rename, "bin", file)
        )

      end

    end

  end

  #
  # Copy required Postgresql files on to the stage
  #
  def self.stage_postgresql

    PostgresServer.files.each do |file|

      if File.exist?(File.join(Stage, file))

        FileUtils.cp(
          File.join(Stage, PostgresServer.target, "bin", file),
          File.join(Stage, Ruby187.rename, "bin", file)
        )

      end

    end

  end

  #
  # Add functionality to DevKit object that was loaded during configure.
  #
  def self.link_devkit_with_ruby

    devkit_path = File.join(Stage, DevKit.target)

    ruby_path = File.join(Stage, Ruby187.rename)

    FileUtils.mkdir_p(devkit_path) unless File.directory?(devkit_path)

    Dir.chdir(devkit_path) do

      File.open("config.yml", 'w') do |file|

        file.write(%Q(---\n- #{ruby_path}))

      end

      sh %Q{#{File.join(ruby_path, "bin", "ruby")} dk.rb install}

    end

  end

  def self.stage_git
    # TODO: adjust git config for CRLF => LF autoadjust.

    gitconfig = File.join(Stage, Git.target, "etc", "gitconfig")

    config = File.read(gitconfig)

    File.open(gitconfig, "w") do |config_file|

      config_file.write(config.gsub(/autocrlf = true/, "autocrlf = false"))

    end

  end

  def self.stage_gems
    section Gems

    build_gems(File.join(Stage, Ruby187.rename), Gems.list)

    build_gem(File.join(Stage, Ruby187.rename), "pg", {
      :args => [
          "--",
          "--with-pg-include=#{File.join(Stage, "pgsql", "include")}",
          "--with-pg-lib=#{File.join(Stage, "pgsql", "lib")}"
      ].join(' ')
    })
  end

  def self.stage_rails_sample_application
    # Generate sample rails application in the Rails application directory on
    # stage.
    section Rails
    sample = File.join(Stage, "Sites", "sample")
    FileUtils.rm_rf(sample) if File.exist?(sample)
    ruby_binary("rails", "new", "sample", File.join(Stage, Ruby187.rename))
  end

  def self.stage_msvc_runtime
    # MSVC Runtime 2008
    # Required for Postgresql Server
    download(MsvcRuntime)

    # FileUtils.mv(
    #   File.join(RailsInstaller::Archives, File.basename(MsvcRuntime.url)),
    #   File.join(RailsInstaller::Stage, File.basename(MsvcRuntime.url))
    # )
  end

  #
  # build_gems
  #
  # loops over each gemname and triggers it to be built.
  def self.build_gems(ruby_path, gems)

    if gems.is_a?(Array)

      gems.each do |name|

        build_gem(ruby_path, name)

      end

    elsif gems.is_a?(Hash)

      gems.each_pair do |name, version |

        build_gem(ruby_path, name,version)

      end

    else

      build_gem(gems)

    end

  end

  def self.build_gem(ruby_path, gemname, options = {})

    printf " => Staging gem #{gemname}\n" if $Flags[:verbose]

    %w(GEM_HOME GEM_PATH).each { |variable| ENV.delete(variable)}

    command = %Q(#{File.join(ruby_path, "bin", "gem")} install #{gemname})

    command += %Q( -v#{options[:version]} ) if options[:version]

    command += %Q( --no-rdoc --no-ri )

    command += options[:args] if options[:args]

    sh command

  end

  def self.ruby_binary(name, command, action, ruby_path, options = {})

    printf " => rails #{command} #{action}\n" if $Flags[:verbose]

    %w(GEM_HOME GEM_PATH).each { |variable| ENV.delete(variable)}

    command = %Q(#{File.join(ruby_path, "bin", "ruby")} -S #{name} #{command} #{action})

    command += options[:args] if options[:args]

    applications_path = File.join(RailsInstaller::Stage, "Sites")

    FileUtils.mkdir_p applications_path unless File.exist?(applications_path)

    Dir.chdir(applications_path) { sh command }

  end

  def self.iscc(*params)
    executable = nil

    # look for InnoSetup compiler in the PATH
    found = ENV['PATH'].split(File::PATH_SEPARATOR).find do |path|
      File.exist?(File.join(path, 'iscc.exe')) && File.executable?(File.join(path, 'iscc.exe'))
    end

    # not found?
    if found
      executable = 'iscc.exe'
    else
      path = File.join(ENV['ProgramFiles'], 'Inno Setup 5')
      if File.exist?(File.join(path, 'iscc.exe')) && File.executable?(File.join(path, 'iscc.exe'))
        path.gsub!(File::SEPARATOR, File::ALT_SEPARATOR)
        ENV['PATH'] = "#{path}#{File::PATH_SEPARATOR}#{ENV['PATH']}" unless ENV['PATH'].include?(path)
        executable = 'iscc.exe'
      end
    end

    cmd = [executable]
    cmd.concat(params)

    sh cmd.join(' ')
  end

  #
  # sh
  #
  # Runs Shell commands, single point of shell contact.
  #
  def self.sh(command, options = {})

    stage_bin_path = File.join(RailsInstaller::Stage, "bin")

    ENV["PATH"] = "#{stage_bin_path};#{ENV["PATH"]}" unless ENV["PATH"].include?(stage_bin_path)

    printf "\nDEBUG: > %s\n\n", command if $Flags[:verbose]

    output, error, status = Open3.capture3(command)

    if $Flags[:verbose]
      puts output
      puts error unless error.empty?
    end
  end


  def self.log(text)
    printf %Q[#{text}\n]
  end

  def self.section(text)
    printf %Q{\n== #{text}\n\n}
  end

end


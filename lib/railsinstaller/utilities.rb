module RailsInstaller::Utilities
  #
  # unzip:
  # Requires: rubyzip2 (gem install rubyzip2) # require "zip/zip"
  #
  def unzip(package)

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
  def extract(package)

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
  def install_utility

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
  # build_gems
  #
  # loops over each gemname and triggers it to be built.
  def build_gems(ruby_path, gems)

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

  def build_gem(ruby_path, gemname, options = {})

    printf " => Staging gem #{gemname}\n" if $Flags[:verbose]

    %w(GEM_HOME GEM_PATH).each { |variable| ENV.delete(variable)}

    command = %Q(#{File.join(ruby_path, "bin", "gem")} install #{gemname})

    command += %Q( -v#{options[:version]} ) if options[:version]

    command += %Q( --no-rdoc --no-ri )

    command += options[:args] if options[:args]

    sh command

  end

  #
  # sh
  #
  # Runs Shell commands, single point of shell contact.
  #
  def sh(command, options = {})

    stage_bin_path = File.join(RailsInstaller::Stage, "bin")

    ENV["PATH"] = "#{stage_bin_path};#{ENV["PATH"]}" unless ENV["PATH"].include?(stage_bin_path)

    printf "\nDEBUG: > %s\n\n", command if $Flags[:verbose]

    output, error, status = Open3.capture3(command)

    if $Flags[:verbose]
      puts output
      puts error unless error.empty?
    end
  end


  def log(text)
    printf %Q[#{text}\n]
  end

  def section(text)
    printf %Q{\n#\n# #{text}\n#\n\n}
  end
end

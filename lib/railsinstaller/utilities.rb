module RailsInstaller::Utilities
  #
  # unzip:
  # Requires: rubyzip2 (gem install rubyzip2) # require "zip/zip"
  #
  def unzip(filename, options = {})

    regex       = options[:regex]
    base_path   = File.dirname(filename)
    target_path = options[:target_path] || base_path
    filename    = File.basename(filename)
    files       = []

    printf " => Extracting #{filename} contents\n"

    Dir.chdir(base_path) do

      Zip::ZipFile.open(filename) do |zipfile|
        printf "zipfile: #{zipfile.inspect}\n" if $Flags[:verbose]

        if regex

          entries = zipfile.entries.select do |entry|

            entry.name.match(regex)

          end

        else
          entries = zipfile.entries
        end

        printf "DEBUG: $PWD=#{Dir.pwd}\n" if $Flags[:verbose]

        entries.each do |entry|

          printf "DEBUG: Extracting #{entry.name}\n" if $Flags[:verbose]
          
          files << entry.name

          FileUtils.rm_f(entry.name) if File.exists?(entry.name)

          zipfile.extract(entry, entry.name)

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
  def extract(filename, options = Hash.new(nil))

    unless File.exists?(filename)
      raise "ERROR: #{file} does not exist, did the download step fail?"
    end

    options[:force] ||= false
    base_path   = File.dirname(filename)
    target_path = options[:target_path] || base_path
    bsdtar      = File.join(RailsInstaller::Stage, "bin", RailsInstaller::BSDTar.binary)
    sevenzip    = File.join(RailsInstaller::Stage, "bin", RailsInstaller::SevenZip.binary)

    printf " => Extracting '#{filename}' into '#{target_path}'\n" if $Flags[:verbose]

    FileUtils.mkdir_p(base_path) unless Dir.exist?(base_path)

    if base_path != target_path && Dir.exist?(target_path)
      FileUtils.rm_rf(target_path)
      return unless options[:force]
    end

    Dir.chdir(base_path) do

      case filename
        when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/, /(^.+\.tar)\.lzma$/, /(^.+)\.tgz$/
          command = %Q("#{bsdtar}" -xf "#{filename}") #  > NUL 2>&1")
        when /^.+\.7z$/
          command = %Q("#{sevenzip}" x -t7z -o#{target_path} "#{filename}") #  > NUL 2>&1")
        when /^.+sfx\.exe$/
          command = %Q("#{sevenzip}" x -t7z -sfx -o#{target_path} #{filename})
        when /(^.+\.zip$)/
          if $Flags[:bootstrapped]
            # Use bsdtar once we already have it
            command = %Q("#{bsdtar}" -xf "#{filename}") #  > NUL 2>&1")
          else
            # For the unzip case we can return a list of extracted files.
            return unzip(filename, :regex => options[:regex])
          end
        else
          raise "\nERROR:\n  Cannot extract #{filename}, unhandled file extension!\n"
      end

      if $Flags[:verbose]
        puts(sh(command))
      else
        sh command
      end

    end

  end


  #
  # install_utility()
  #
  # Requires: open-uri
  #
  def install_utility(url, binary, path = File.join(RailsInstaller::Stage, "bin"))

    if File.exists?(File.join(path, binary))

      printf "#{File.join(path, binary)} exists.\nSkipping download, extract and install.\n"

    else
      printf " => Downloading and extracting #{binary} from #{url}\n"

      stage_path = RailsInstaller::Stage

      FileUtils.mkdir_p(stage_path) unless Dir.exists?(stage_path)

      Dir.chdir(stage_path) do

        filename = File.basename(url)

        FileUtils.rm_f(filename) if File.exist?(filename)

        # BSDTar is small so using open-uri to download this is fine.
        open(url) do |temporary_file|

          File.open(filename, "wb") do |file|

            file.write(temporary_file.read)

          end

        end

        extract(filename, {:regex => Regexp.new(binary)}).each do |file|

          printf " => Instaling #{file} to #{path}\n"

          FileUtils.mkdir_p(path) unless Dir.exist?(path)

          FileUtils.mv(
            File.join(RailsInstaller::Stage, file),
            File.join(path, file),
            :force => true
          )

        end

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

    %x(#{command})

  end


  def log(text)
    printf %Q[#{text}\n]
  end

  def section(text)
    printf %Q{\n#\n# #{text}\n#\n\n}
  end
end

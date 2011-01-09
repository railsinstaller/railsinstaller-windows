require "open-uri"
require "fileutils"

gem "rubyzip2", "~> 2.0.1"
require "zip/zip"

module RailsInstaller::Utilities
  #
  # unzip:
  # Requires: rubyzip2 (gem install rubyzip2) # require "zip/zip"
  #
  def unzip(filename, options = {})

    regex = options[:regex]
    base_path = File.dirname(filename)
    target_path = options[:target_path] || base_path

    printf "Extracting #{filename} contents\n"

    files = []

    Zip::ZipFile.open(filename) do |zipfile|

      zipfile.entries.select do |entry|

        entry.name.match(/.*\.exe$/)

      end.each do |entry|

        files << entry.name

        FileUtils.rm_f(entry.name) if File.exists?(entry.name)

        zipfile.extract(entry, entry.name)

      end

    end

    files

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
      printf "Downloading and extracting #{binary} from #{url}\n"

      Dir.chdir(RailsInstaller::Stage) do
        filename = File.basename(RailsInstaller::SevenZip.url)
        FileUtils.rm_f(filename) if File.exist?(filename)

        # BSDTar is small so using open-uri to download this is fine.
        open(url) do |temporary_file|
          File.open(filename, "wb") do |file|
            file.write(temporary_file.read)
          end
        end

        extract(filename, {:regex => Regexp.new(binary)}).each do |file|
          printf "Instaling #{file} to #{path}\n"
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
  # sh
  #
  # Runs Shell commands, single point of shell contact.
  #
  def sh(command, options = {})
    stage_bin_path = File.join(RailsInstaller::Stage, "bin")
    ENV["PATH"] = "#{stage_bin_path};#{ENV["PATH"]}" unless ENV["PATH"].include?(stage_bin_path)
    if $Flags[:verbose]
      printf " => command:\n > %s\n", command
      puts %x(#{command})
    else
      %x(#{command})
    end
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

    base_path = File.dirname(filename)
    target_path = options[:target_path] || base_path

    if $Flags[:verbose]
      printf "Extracting:\n  #{filename}\ninto:\n  #{target_path}\n"
    end

    bsdtar = File.join(RailsInstaller::Stage, "bin", RailsInstaller::BSDTar.binary)
    sevenzip = File.join(RailsInstaller::Stage, "bin", RailsInstaller::SevenZip.binary)
    Dir.chdir(base_path) do
      case filename
        when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/, /(^.+\.tar)\.lzma$/, /(^.+)\.tgz$/
          sh = %Q("#{bsdtar}" -xf "#{filename}") #  > NUL 2>&1")
        when /^.+\.7z$/
          sh = %Q("#{sevenzip}" x -t7z -o#{target_path} "#{filename}") #  > NUL 2>&1")
        when /^.+sfx\.exe$/
          sh = %Q("#{sevenzip}" x -t7z -sfx -o#{target_path} #{filename})
        when /(^.+\.zip$)/
          # For the unzip case we can return a list of extracted files.
          return unzip(filename, :regex => options[:regex])
        else
          raise "\nERROR:\n  Cannot extract #{filename}, unhandled file extension!\n"
      end
    end
  end

  #
  # build_gems
  #
  # loops over each gemname and triggers it to be built.
  def build_gems(gems)
    if gems.is_a?(Hash)
      gems.each do |name|
        build_gem(name)
      end
    elsif gems.is_a?(Array)
      gems.each_pair do |name, version |
        build_gem(name,version)
      end
    else
      build_gem(gems)
    end
  end

  def build_gem(gemname, options = {})

    if $Flags[:verbose]
      printf "Building gem #{gemname}\n"
    end

    if options[:version]
      installer = Gem::DependencyInstaller.new(
        :install_dir => File.join(RailsInstaller::Stage, "#{gemname}-#{options[:version]}")
      )
      installer.install(gemname, options[:version])
    else
      installer = Gem::DependencyInstaller(
        :install_dir => File.join(RailsInstaller::Stage, "#{gemname}")
      )
      installer.install(gemname)
    end
    # TODO: bundle .gem file
  end

  def log(text)
    printf %Q[#{text}\n]
  end

  def section(text)
    printf %Q{\n#\n# #{text}\n#\n\n}
  end
end

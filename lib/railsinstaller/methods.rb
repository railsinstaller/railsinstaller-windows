module RailsInstaller

  def self.sh(command, *options)
    %x{#{command}}
  end

  def self.extract(file)

    unless File.exists?(File.expand_path(file))
      raise "ERROR: #{file} does not exist, did the download step fail?"
    end

    filename = File.expand_path(file)

    if $Flags[:verbose]
      printf "Extracting #{filename} into #{File.dirname(filename)}\n"
    end

    Dir.chdir(File.dirname(filename)) do
      case filename
      when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/, /(^.+\.tar)\.lzma$/, /(^.+)\.tgz$/
        %x{"#{RailsInstaller::Utilities::BSDTar.binary}" -xf "#{filename}" > NUL 2>&1"}
      when /(^.+\.zip$)/
        # TODO: use bsd_tar_extract to unzip the file
        %x{"#{RailsInstaller::Utilities::BSDTar.binary}" -xf??? "#{filename}" > NUL 2>&1"}
      else
        raise "ERROR: Cannot extract #{filename}, unknown extension!"
      end
    end
  end

  def self.download(url, filename)

    if $Flags[:verbose]
      printf "Downloading #{filename} from #{url}\n"
    end

    open(url) do |temporary_file|
      File.open(filename,"wb") do |file|
        file.write(temporary_file.read)
      end
    end

  end

  def self.build_gems(gems)
    gems.each do |gemname|
      build_gem(gemname)
    end
  end

  def self.build_gem(gemname, *options)

    if $Flags[:verbose]
      printf "Building gem #{gemname}\n"
    end

  end

  def self.log(text)
    printf %Q[#{text}\n]
  end

  def self.section(text)
    printf %Q{#\n# #{text}\n#\n}
  end

  def self.build!

    #
    # Configuration / Variables
    #
    stage_path="#{RailsInstaller::Root}/stage"

    #
    section "RubyInstaller"
    #
    url = RubyInstaller.versions["1.8.7-p330"]
    filename = "#{stage_path}/#{File.basename(url)}"

    download(url, filename) and extract(filename)

    #
    section "DevKit"
    #
    url = DevKit.url
    filename = File.basename(DevKit.filename)
    download(url, filename) and extract(filename)

    DevKit.init_ruby("#{stage_path}\\DevKit",
                     "#{stage_path}\\rubyinstaller\\Ruby187\\bin")

    #
    section "Gems"
    #
    build_gems(%w(rake rails mysql pg))

    #
    # Git
    #
    download(Git.url, Git.filename) and extract(Git.filename)

  end

end

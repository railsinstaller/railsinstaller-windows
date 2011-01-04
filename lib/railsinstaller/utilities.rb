module RailsInstaller

  #
  # unzip:
  # Requires: rubyzip2 (gem install rubyzip2)
  #
  def self.unzip(filename, regex = nil)

    require "zip/zip"

    Zip::ZipFile.open(File.basename(BSDTar.url)) do |zipfile|

      zipfile.entries.select do |entry|

        entry.name.match(/.*\.exe$/)

      end.each do |entry|

        zipfile.extract(entry, entry.name)

      end

    end

  end

  #
  # bsdtar_install
  # Requires: open-uri
  #
  def self.bsdtar_install(path = "#{Root}\\stage\\bin")

    require "open-uri"

    require "fileutils"

    FileUtils.mkdir_p(File.dirname(path))

    # BSDTar is small so using open-uri to download this is fine.
    open(BSDTar.url) do |temporary_file|

      File.open(File.basename(BSDTar.url),"wb") do |file|

        file.write(temporary_file.read)

      end

    end

    unzip(File.basename(BSDTar.url), /.*\.exe$/)

    FileUtils.mv("basic-bsdtar.exe", path)

  end

  #
  # sh
  #
  # Runs Shell commands, single point of shell contact.
  #
  def self.sh(command, *options)
    %x{#{command}}
  end

  #
  # extract
  #
  # Used to extract a non-zip file using BSDTar
  #
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
        unzip(filename)
      else
        raise "ERROR: Cannot extract #{filename}, unknown extension!"
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


end

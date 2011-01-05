require "open-uri"
require "fileutils"
require "zip/zip"

module RailsInstaller::Utilities
#
# unzip:
# Requires: rubyzip2 (gem install rubyzip2) # require "zip/zip"
#
  def unzip(filename, regex = nil)

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
  def bsdtar_install(path = File.join(RailsInstaller::Stage, "bin"))

    FileUtils.mkdir_p(File.dirname(path))

    # BSDTar is small so using open-uri to download this is fine.
    open(BSDTar.url) do |temporary_file|

      File.open(File.basename(BSDTar.url), "wb") do |file|

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
  def sh(command, *options)

    stage_bin_path = File.join(RailsInstaller::Stage, "bin")
    ENV["PATH"] = "#{stage_bin_path};#{ENV["PATH"]}" unless ENV["PATH"].include?(stage_bin_path)

    %x(#{command})
  end

#
# extract
#
# Used to extract a non-zip file using BSDTar
#
  def extract(file)

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
          puts sh %Q("#{RailsInstaller::BSDTar.binary}" -xf "#{filename}") #  > NUL 2>&1")
        when /^.+\.7z$/
          puts sh %Q("#{RailsInstaller::BSDTar.binary}" -xf "#{filename}") #  > NUL 2>&1")
        when /(^.+\.zip$)/
          unzip(filename)
        else
          raise "ERROR: Cannot extract #{filename}, unhandled file extension!"
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

  def build_gem(gemname, *options)

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
    printf %Q{\n#\n# #{text}\n#\n}
  end
end

module RailsInstaller

  #
  # Add functionality to DevKit object that was loaded during configure.
  #
  def self.install_devkit_into_ruby(devkit_path,ruby_bin_path)

    FileUtils.mkdir_p(devkit_path) unless File.directory?(devkit_path)

    Dir.chdir(devkit_path) do

      File.open("config.yml", 'w') do |file|

        file.write(%Q(---\n- #{ruby_bin_path}))

      end

      sh %Q{#{File.join(ruby_bin_path, "ruby")} dk.rb install}

    end

  end

end

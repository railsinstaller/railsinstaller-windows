module RailsInstaller

  #
  # Add functionality to DevKit object that was loaded during configure.
  #
  def self.install_devkit_into_ruby(devkit_path,ruby_path)

    unless ENV["PATH"].include?("#{ruby_path}")
      ENV["PATH"] = "#{ruby_path};#{ENV["PATH"]}"
    end

    FileUtils.mkdir_p(devkit_path) unless Dir.exists?(devkit_path)

    Dir.chdir(devkit_path) do
      File.open("config.yml", 'w') do |file|
        file.write(%Q(---\n- #{ruby_path}))
      end

      sh %Q{ruby dk.rb install}
    end

  end

end

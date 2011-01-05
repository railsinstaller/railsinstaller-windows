module RailsInstaller

  #
  # Add funcitonality to DevKit object that was loaded during configure.
  #
  def self.install_devkit_into_ruby(devkit_path,ruby_path)

    unless ENV["PATH"].include?("#{path}")
      ENV["PATH"] = "#{ruby_path};#{ENV["PATH"]}"
    end

    sh %Q{cd "#{File.join(devkit_path, "DevKit")}" && ruby dk.rb init}

    sh %Q{cd "#{File.join(devkit_path, "DevKit")}" && ruby dk.rb install}

  end

end

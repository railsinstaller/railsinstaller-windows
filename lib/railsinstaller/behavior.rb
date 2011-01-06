module RailsInstaller

  #
  # Add functionality to DevKit object that was loaded during configure.
  #
  def self.install_devkit_into_ruby(devkit_path,ruby_path)

    unless ENV["PATH"].include?("#{ruby_path}")
      ENV["PATH"] = "#{ruby_path};#{ENV["PATH"]}"
    end

    sh %Q{cd "#{devkit_path}" && ruby dk.rb init}

    sh %Q{cd "#{devkit_path}" && ruby dk.rb install}

  end

end

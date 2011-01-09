module RailsInstaller

  #
  # Load initial objects (OpenStruct) from railsinstaller.yml
  #
  %w[utilities compilers components].each do |name|

    yaml = ERB.new(File.read("#{RailsInstaller::Root}/config/railsinstaller.yml"), 0).result(binding)

    YAML.load(yaml)[name].each_pair do |key,value|

      printf "  => #{value[:name]} = #{value.inspect}\n" if $Flags[:verbose]

      const_set(value[:name], OpenStruct.new(value))

    end

  end
end

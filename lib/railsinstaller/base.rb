module RailsInstaller

  %w{utilities compilers components}.each do |name|

    # TODO: Run through ERB.
    #config = OpenStruct.new(Erb.parse(YAML.load_file(file)))
    yaml = ERB.new(File.read("#{RailsInstaller::Root}/config/railsinstaller.yml"), 0).result(binding)

    YAML.load(yaml)[name].each_pair do |key,value|
      printf "  => #{value[:name]} = #{value.inspect}\n" #if $Flags[:verbose]

      const_set(value[:name], OpenStruct.new(value))
    end

  end

end

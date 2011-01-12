module RailsInstaller

  #
  # Load initial objects (OpenStruct) from railsinstaller.yml
  #
  @@config = YAML.load(
    ERB.new(
      File.read(
        File.join(Root, "config", "railsinstaller.yml")
      )
    ).result(binding)
  )

  printf "DEBUG: Config: #{@@config.inspect}" if $Flags[:verbose]

  @@config.each_pair do |key,value|

    printf "  => #{value[:name]} = #{value.inspect}\n" if $Flags[:verbose]

    const_set(value[:name], OpenStruct.new(value))

  end

end

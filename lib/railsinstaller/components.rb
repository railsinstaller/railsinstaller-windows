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

  @@config.each_pair do |key,value|
    const_set(value[:name], OpenStruct.new(value))
  end
end

module RailsInstaller::Helpers

  def self.included(target_module)

    # Define configure on the given module
    def target_module.configure(name)

      # TODO: Run through ERB.
      #config = OpenStruct.new(Erb.parse(YAML.load_file(file)))
      yaml = ERB.new(File.read("#{RailsInstaller::Root}/config/base.yml"), 0).result(binding)
      config = OpenStruct.new(YAML.load(yaml)[name])

      config.each_pair do |key,value|

        printf "  => #{self.name}::#{value.name} = #{value.inspect}\n" if $Flags[:verbose]
        const_set(value.name, value)

      end

    end

  end

end

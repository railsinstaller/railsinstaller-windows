module RailsInstaller::Helpers

  def self.included(target_module)

    # Define configure on the given module
    def target_module.configure(name)

      Dir["#{RailsInstaller::Root}/config/#{name}/*.yml"].each do |file|

        config = OpenStruct.new(YAML.load_file(file))

        printf "  => #{self.name}::#{config.name} = #{config.inspect}\n" if $Flags[:verbose]

        const_set(config.name, config)

      end

    end

  end

end

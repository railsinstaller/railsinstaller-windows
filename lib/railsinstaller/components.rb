module RailsInstaller::Components

  def self.included(target_module)

    # Define configure on the given module
    def target_module.configure(name)

      target_module.class_eval do
        include RailsInstaller::Helpers

        configure "components"
      end

    end

  end

end

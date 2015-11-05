module CloudlessBox
  module Timing
    def at_compile_time(&block)
      CompileTime.new(self).evaluate(&block)
    end

    private

    class CompileTime
      def initialize(recipe)
        @recipe = recipe
      end

      def evaluate(&block)
        instance_eval(&block)
      end

      def method_missing(m, *args, &block)
        resource = @recipe.send(m, *args, &block)
        if resource.is_a?(Chef::Resource)
          actions = Array(resource.action)
          resource.action(:nothing)

          actions.each do |action|
            resource.run_action(action)
          end
        end
        resource
      end
    end
  end
end

Chef::Recipe.send(:include, CloudlessBox::Timing)

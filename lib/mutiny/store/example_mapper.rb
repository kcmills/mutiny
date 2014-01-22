require "mutiny/example"

module Mutiny
  module Store
    class ExampleMapper
      def serialise(example)
        { 
          spec_path: example.spec_path,
          name: example.name
        }
      end
      
      def deserialise(memento)
        Example.new(memento)
      end
    end
  end
end
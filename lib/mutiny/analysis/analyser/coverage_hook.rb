require_relative "../../integration/hook"

module Mutiny
  module Analysis
    class Analyser
    
      class CoverageHook < Integration::Hook
        '''
        This the hook passed into the test suite when gathering the coverage information to enable the lines of code executed by
        each test individually to be traced and stored.
        '''
        def initialize(project_root_folder)
          @root = project_root_folder
        end

        def before(example)
          test_location = example.metadata.fetch(:location)
          @trace = TracePoint.new() do |tp|

            if tp.path.to_s.include?(@root)
            
              if coverage[tp.path] == nil
                coverage[tp.path] = {tp.lineno=>[test_location]}
              else
                existing_test_array = coverage[tp.path][tp.lineno]
                if existing_test_array == nil
                  coverage[tp.path][tp.lineno] = [test_location]
                elsif !existing_test_array.include?(test_location)
                  coverage[tp.path][tp.lineno].push(test_location)
                end
              end
              
            end
            
          end 
          @trace.enable
        end

        def after(example)
          @trace.disable
        end

        def coverage
          @coverage ||= {}
        end
      end
      
    end
  end
end
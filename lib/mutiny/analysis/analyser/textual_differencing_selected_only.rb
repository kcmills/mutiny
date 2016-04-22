require_relative "../analyser"
require_relative "../../integration/hook"
require_relative "coverage_hook"

module Mutiny
  module Analysis
    class Analyser
      class TextualDifferencing_SelectedOnly < self
        '''
        This class overrides methods in the default analyser to collect coverage information about the test suite using the
        coverage hook and use this to select and run the tests that execute the line(s) changed by each mutant, on the mutant.
        '''
        
        def before_all(mutant_set)
          @subject_set = Subjects::SubjectSet.new(mutant_set.subjects)
          root = mutant_set.subjects[0].root.to_s
          @full_test_set = integration.tests
          integration.run(@full_test_set, hooks: [new_coverage_hook(root)])
          puts "---"
          puts "Coverage: " + coverage_hook.coverage.to_s
          puts "---"
        end

        def select_tests(mutant)
          relevant_tests = []
          coverage_hook.coverage.each_key do |file_path| 
            if file_path.include?(mutant.subject.relative_path)
              mutant.location.lines.each do |lineno|
                array_of_tests = coverage_hook.coverage[file_path][lineno]
                if array_of_tests != nil
                  relevant_tests = (relevant_tests + array_of_tests).uniq
                end
              end
              break
            end
          end
          
          @full_test_set.subset { |test| relevant_tests.include?(test.location) }
        end

        def new_coverage_hook(root)
          @coverage_hook ||= CoverageHook.new root
        end
        
        def coverage_hook
          @coverage_hook
        end
      end
      
    end
  end
end

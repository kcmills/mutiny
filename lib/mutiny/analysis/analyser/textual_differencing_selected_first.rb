require_relative "../analyser"
require_relative "../../integration/hook"
require_relative "coverage_hook"

module Mutiny
  module Analysis
    class Analyser
      class TextualDifferencing_SelectedFirst < self
        '''
        This class overrides methods in the default analyser to collect coverage information about the test suite using the
        coverage hook and use this to select and run the tests that execute the line(s) changed by each mutant, on the mutant.
        If these tests do not kill the mutant, then any tests not previously selected are ran on it.
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
        
        def select_tests(relevant_tests)
          @full_test_set.subset { |test| relevant_tests.include?(test.location) }
        end
        
        def select_remaining_tests(relevant_tests)
          @full_test_set.subset { |test| !relevant_tests.include?(test.location) }
        end
        
        def determine_relevant_tests(mutant)
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

          relevant_tests
        end
        
        def new_coverage_hook(root)
          @coverage_hook ||= CoverageHook.new root
        end
        
        def coverage_hook
          @coverage_hook
        end
        
        def run_tests(mutant)
          relevant_tests = determine_relevant_tests(mutant)
          test_run = run_selected_test_set(relevant_tests)
          if test_run.failed?
            [test_run]
          else
            second_test_run = run_rest_of_test_set(relevant_tests)
            [test_run, second_test_run]
          end
        end
        
        def run_selected_test_set(relevant_tests)
          Isolation.call do
            test_set = select_tests(relevant_tests)
            integration.run(test_set, fail_fast: true)
          end
        end
        
        def run_rest_of_test_set(relevant_tests)
          Isolation.call do
            test_set = select_remaining_tests(relevant_tests)
            integration.run(test_set, fail_fast: true)
          end
        end
      
      end

    end
  end
end

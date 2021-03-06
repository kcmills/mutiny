require_relative "../output/table"

module Mutiny
  class Mode
    class Score < self
      def run
        report "Scoring..."
        report "#{mutant_set.size} mutants, #{results.kill_count} killed"
        report ""
        report summary
      end

      private

      def summary
        Output::Table.new.tap do |summary|
          summary.add_row(summary_header)
          summary.add_rows(results.mutants.ordered.map { |m| summarise(m) })
        end
      end

      def summary_header
        ["Mutant", "Status", "# Tests", "Time"]
      end

      def summarise(mutant)
        identifier = mutant.identifier
        status = status_for_mutant(mutant)
        [identifier, status] + summarise_tests(mutant)
      end

      def status_for_mutant(mutant)
        if mutant.stillborn?
          "stillborn"
        elsif results.survived?(mutant)
          "survived"
        else
          "killed"
        end
      end

      def summarise_tests(mutant)
        if mutant.stillborn?
          number_of_tests = "n/a"
          runtime = "n/a"
        else
          # Modified to enable the mutant information to be gathered from multiple test runs per mutant
		  executed_count = results.test_run_for(mutant).inject(0){ |sum, run| sum + run.executed_count}
		  total_count = results.test_run_for(mutant).inject(0){ |sum, run| sum + run.tests.size}
		  runtime = results.test_run_for(mutant).inject(0){ |sum, run| sum + run.runtime}
		  
          number_of_tests = "#{executed_count} (of #{total_count})"
        end
        [number_of_tests, runtime]
      end

      def results
        @results ||= configuration.analyser.call(mutant_set)
      end

      def mutant_set
        @mutant_set ||= initialize_mutant_set
      end

      def initialize_mutant_set
        if options[:cached]
          configuration.mutant_storage.load_for(environment.subjects)
        else
          configuration.mutator.mutants_for(environment.subjects)
        end
      end
    end
  end
end

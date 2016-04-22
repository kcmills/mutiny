require_relative 'pattern'
require_relative 'reporter/stdout'
require_relative 'integration/rspec'
require_relative 'mutants/ruby'
require_relative 'mutants/storage'
require_relative 'analysis/analyser/default'
require_relative 'analysis/analyser/textual_differencing_selected_only'
require_relative 'analysis/analyser/textual_differencing_selected_first'

module Mutiny
  class Configuration
    attr_reader :loads, :requires, :patterns
    attr_reader :reporter, :integration, :mutator, :mutant_storage, :analyser

    def initialize(loads: [], requires: [], patterns: [])
      @loads = loads
      @requires = requires
      @patterns = patterns
      @patterns.map!(&Pattern.method(:new))

      @reporter = Reporter::Stdout.new
      @integration = Integration::RSpec.new
      @mutator = Mutants::Ruby.new
      @mutant_storage = Mutants::Storage.new
	  
	  ''' 
	  The analyser component can be set to one of the following:
		Default - Selects tests for each mutant based on the mutant`s subject and only runs these tests on the mutant
		TextualDifferencing_SelectedOnly - Selects tests for each mutant based on the coverage information of the test suite
			and only runs these tests on the mutant
		TextualDifferencing_SelectedFirst - Selects tests for each mutant based on the coverage information of the test suite,
			runs these tests and then, if the mutant has not been killed, runs any tests not previously selected on the mutant
	  '''
      @analyser = Analysis::Analyser::TextualDifferencing_SelectedFirst.new(integration: @integration)

    end

    def load_paths
      loads.map(&File.method(:expand_path))
    end

    def can_load?(source_path)
      load_paths.any? { |load_path| source_path.start_with?(load_path) }
    end
  end
end

require "parser/current"
require_relative "mutation_operators/binary_operator"

module Mutiny
  class Mutator
    def mutate(program)
      ast = Parser::CurrentRuby.parse(program.code)
      operators.flat_map { |operator| operator.mutate(ast, program.path) }
    end
  
  private
    def operators
      [ Mutiny::MutationOperators::BinaryOperator.new ]
    end
  end
end
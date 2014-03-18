require_relative "mutation_operators/relational_operator_replacement"
require_relative "mutation_operators/relational_expression_replacement"
require_relative "mutation_operators/unary_arithmetic_operator_replacement"
require_relative "mutation_operators/unary_arithmetic_operator_deletion"
require_relative "mutation_operators/unary_arithmetic_operator_insertion"
require_relative "mutation_operators/binary_arithmetic_operator_replacement"
require_relative "mutation_operators/conditional_operator_replacement"
require_relative "mutation_operators/shortcut_assignment_operator_replacement"
require_relative "mutation_operators/logical_operator_replacement"

module Mutiny
  module Mutator
    class MutationOperatorRegistry
      def operator_for(name)
        operators_by_name[name.to_sym]
      end
  
    private
      def operators_by_name
        @operators_by_name ||= {
          ROR: MutationOperators::RelationalOperatorReplacement.new,
          RER: MutationOperators::RelationalExpressionReplacement.new,
          UAOR: MutationOperators::UnaryArithmeticOperatorReplacement.new,
          UAOD: MutationOperators::UnaryArithmeticOperatorDeletion.new,
          UAOI: MutationOperators::UnaryArithmeticOperatorInsertion.new,
          BAOR: MutationOperators::BinaryArithmeticOperatorReplacement.new,
          COR: MutationOperators::ConditionalOperatorReplacement.new,
          SAOR: MutationOperators::ShortcutAssignmentOperatorReplacement.new,
          LOR: MutationOperators::LogicalOperatorReplacement.new
        }
      end
    end
  end
end
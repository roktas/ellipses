# frozen_string_literal: true

module Ellipses
  module Support
    module_function

    def to_range(index_or_range)
      case index_or_range
      when Range then index_or_range
      when Integer then Range.new(index_or_range, index_or_range)
      else raise ArgumentError, "Integer or a Range expected where found: #{index_or_range.class}"
      end
    end
  end
end

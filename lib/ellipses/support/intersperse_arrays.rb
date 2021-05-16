# frozen_string_literal: true

module Ellipses
  module Support
    module_function

    def intersperse_arrays(arrays, intersperse)
      interspersed = []
      arrays.each { |array| interspersed.append(array, intersperse) }
      interspersed.pop
      interspersed
    end
  end
end

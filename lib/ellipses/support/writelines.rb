# frozen_string_literal: true

module Ellipses
  module Support
    module_function

    def writelines(file, lines)
      ::File.write(file, "#{[*lines].join.chomp}\n")
    end
  end
end

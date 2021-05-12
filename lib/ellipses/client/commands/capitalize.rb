# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Capitalize < Command
        command 'capitalize', argc: 0

        def call(input)
          input.map(&:capitalize)
        end
      end
    end
  end
end

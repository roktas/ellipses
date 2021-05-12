# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Titleize < Command
        command 'titleize', argc: 0

        def call(input)
          input.map(&:titleize)
        end
      end
    end
  end
end

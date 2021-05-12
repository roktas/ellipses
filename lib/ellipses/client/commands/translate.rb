# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Translate < Command
        command 'tr', argc: 2

        def call(input)
          input.map { |line| line.tr(*argv) }
        end
      end
    end
  end
end

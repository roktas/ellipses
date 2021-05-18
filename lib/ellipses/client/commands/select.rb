# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Select < Command
        command 'select', argc: 1

        include Command::Mixins::SetupPattern

        def call(input)
          input.grep param.pattern
        end
      end
    end
  end
end

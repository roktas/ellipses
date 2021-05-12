# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Reject < Command
        command 'reject', argc: 1

        include Command::Mixins::SetupPattern

        def call(input)
          input.grep_v param.pattern
        end
      end
    end
  end
end

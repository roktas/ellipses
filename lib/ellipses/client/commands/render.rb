# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Render < Command
        command 'render', argc: (0..)

        def call(input)
          raise NotImplementedError
        end
      end
    end
  end
end

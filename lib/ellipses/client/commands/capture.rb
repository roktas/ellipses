# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Capture < Command
        command 'capture', argc: (1..)

        def call(*)
          raise NotImplementedError
        end
      end
    end
  end
end

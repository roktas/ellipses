# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Substitute < Command
        command 'sub', argc: 2

        include Command::Mixins::SetupPattern

        def setup
          super

          param.replace = argv.last
        end

        def call(input)
          input.map { |line| line.gsub param.pattern, param.replace }
        end
      end
    end
  end
end

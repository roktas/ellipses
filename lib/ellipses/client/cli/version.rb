# frozen_string_literal: true

module Ellipses
  module Client
    module CLI
      module Commands
        class Version < Dry::CLI::Command
          desc 'Print version'

          def call(*)
            puts Ellipses::VERSION
          end
        end
      end
    end
  end
end

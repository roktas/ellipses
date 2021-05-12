# frozen_string_literal: true

module Ellipses
  module Server
    module CLI
      module Commands
        class Version < Dry::CLI::Command
          desc 'Print version'

          def call(*)
            puts '1.0.0'
          end
        end
      end
    end
  end
end

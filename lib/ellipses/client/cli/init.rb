# frozen_string_literal: true

module Ellipses
  module Client
    module CLI
      module Commands
        class Init < Dry::CLI::Command
          desc 'Initialize repository'

          argument :rootdir, default: '.', desc: 'Root directory'

          example [
            'path/to/rootdir # Initialize repository at root directory'
          ]

          def call(rootdir:, **)
            Application.init(rootdir)
          end
        end
      end
    end
  end
end

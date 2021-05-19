# frozen_string_literal: true

require 'dry/cli'

module Ellipses
  module Server
    module CLI
      module Commands
        class Validate < Dry::CLI::Command
          desc 'Validate repository'

          argument :path, type: :string, required: true, desc: 'Repository path'

          def call(path:)
            Ellipses::Server::Application.validate path
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Ellipses
  module Client
    module CLI
      module Commands
        class Update < Dry::CLI::Command
          desc 'Update'

          option :paths, type: :array, default: %w[.], desc: 'Providers path'

          def call(*, paths:)
            Application.update(paths: paths)
          end
        end
      end
    end
  end
end

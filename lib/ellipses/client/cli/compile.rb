# frozen_string_literal: true

module Ellipses
  module Client
    module CLI
      module Commands
        class Compile < Dry::CLI::Command
          desc 'Compile file'

          argument :file, type: :string, required: true, desc: 'File to be compiled'

          option :paths, type: :array, default: %w[.], desc: 'Providers path'

          def call(file:, paths:)
            Application.compile!(file, paths: paths)
          end
        end
      end
    end
  end
end

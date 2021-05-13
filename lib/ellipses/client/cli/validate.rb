# frozen_string_literal: true

module Ellipses
  module Client
    module CLI
      module Commands
        class Validate < Dry::CLI::Command
          desc "Validate file"

          argument :file, type: :string, required: true, desc: "File to be validated"

          option :paths, type: :array, default: %w[.], desc: "Providers path"

          def call(file:, paths:)
            Application.validate!(file, paths: paths)
          end
        end
      end
    end
  end
end

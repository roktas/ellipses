# frozen_string_literal: true

module Ellipses
  module Client
    module CLI
      module Commands
        class Decompile < Dry::CLI::Command
          desc "Decompile file"

          argument :file, type: :string, required: true, desc: "File to be decompiled"

          option :paths, type: :array, default: %w[.], desc: "Providers path"

          def call(file:, paths:)
            Application.decompile!(file, paths: paths)
          end
        end
      end
    end
  end
end

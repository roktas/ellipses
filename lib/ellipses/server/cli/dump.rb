# frozen_string_literal: true

module Ellipses
  module Server
    module CLI
      module Commands
        class Dump < Dry::CLI::Command
          desc "Dump symbols"

          argument :path,    type: :string, required: true,  desc: "Source path"
          argument :symbols, type: :array,  required: false, desc: "Symbols"

          def call(path:, symbols: [], **)
            puts Ellipses::Server::Application.dump path, *symbols
          end
        end
      end
    end
  end
end

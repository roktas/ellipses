# frozen_string_literal: true

require 'dry/cli'

require 'ellipses/client'

module Ellipses
  module Client
    module CLI
      module Commands
        extend Dry::CLI::Registry

        Dir[File.join(__dir__, 'cli/*.rb')].each { |command| require command }

        register 'compile',   Compile
        register 'decompile', Decompile
        register 'init',      Init
        register 'update',    Update
        register 'validate',  Validate
        register 'version',   Version, aliases: ['v', '-v', '--version']
      end
    end
  end
end

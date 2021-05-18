# frozen_string_literal: true

require 'dry/cli'

require 'ellipses/server'

module Ellipses
  module Server
    module CLI
      module Commands
        extend Dry::CLI::Registry

        Dir[File.join(__dir__, 'cli/*.rb')].each { |command| require command }

        register 'version',  Version, aliases: ['v', '-v', '--version']
        register 'dump',     Dump
        register 'validate', Validate
      end
    end
  end
end

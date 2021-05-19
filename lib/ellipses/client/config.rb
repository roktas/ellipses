# frozen_string_literal: true

require 'forwardable'

module Ellipses
  module Client
    class Config
      extend Forwardable

      def_delegators :@config, *%i[paths]

      def initialize(**options)
        @config = build OpenStruct.new(options.compact)
      end

      private

      def default_paths
        environment = %w[ELLIPSES_PATH SRCPATH].find { |env| ENV.key? env }
        paths       = environment ? ENV[environment].split(':') : []

        ['.', *paths]
      end

      def build(config)
        config.paths = default_paths if !config.paths || config.paths.empty?
        config.paths.compact!

        config
      end
    end
  end
end

# frozen_string_literal: true

require "forwardable"

module Ellipses
  module Client
    class Config
      DEFAULT_ROOTDIR   = "."
      DEFAULT_LOCKFILES = %w[.local/var/src.lock src.lock .src.lock].freeze

      extend Forwardable

      def_delegators :@config, *%i[rootdir paths lockfiles]

      def initialize(**options)
        @config = build OpenStruct.new(options.compact)
      end

      private

      def default_paths
        environment = %w[ELLIPSES_PATH SRCPATH].find { |env| ENV.key? env }
        paths       = environment ? ENV[environment].split(":") : []

        [".", *paths]
      end

      def build(config)
        config.rootdir = Support.dir!(config.rootdir || DEFAULT_ROOTDIR, error: Error)
        config.paths   = default_paths if !config.paths || config.paths.empty?
        config.paths.compact!
        config.lockfiles ||= DEFAULT_LOCKFILES.dup

        config
      end
    end
  end
end

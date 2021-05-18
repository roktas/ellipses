# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      @registry = {}

      def self.available?(name)
        @registry.key? name
      end

      def self.register(name, proto)
        @registry[name] = proto
      end

      def self.proto(name)
        @registry[name]
      end

      Dir[File.join(__dir__, 'commands', '*.rb')].each { |klass| require klass }
    end
  end
end

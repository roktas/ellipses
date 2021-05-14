# frozen_string_literal: true

require "set"

module Ellipses
  module Server
    class Symbols
      CircularReferenceError = Class.new Error

      class Symbol
        attr_reader :depends

        def initialize(meta)
          @meta    = meta
          @depends = []
        end

        def build(symbols)
          return if @meta.depends.nil?

          # To avoid a circular reference, skip dependency if it is this symbol
          @meta.depends.uniq.reject { |depend| depend == to_s }.each { |depend| depends << symbols.register(depend) }
        end

        def to_s
          @meta.to_s
        end

        def path
          @path ||= @meta.path
        end

        class << self
          def from_string(string)
            new Meta::Symbol.from_hash symbol: string
          end

          def from_meta(meta)
            new meta
          end
        end

        private_class_method :new
      end

      private_constant :Symbol

      def initialize(meta)
        @meta     = meta
        @registry = {}

        build
      end

      def [](string)
        @registry[string]
      end

      def resolve(string)
        resolved = []
        walk(self[string]) { |symbol| resolved << symbol }
        resolved
      end

      def register(string)
        _register Symbol.from_string(string)
      end

      def walk(symbol, &block)
        _walk(symbol, Set[symbol], &block)
      end

      private

      def build
        @meta.each { |symbol_meta| _register_by_meta(symbol_meta) }
        @registry.dup.each_value { |symbol| symbol.build(self) }

        sanitize
      end

      def _walk(symbol, stack, &block)
        return if symbol.depends.nil?

        symbol.depends.each do |depend|
          raise CircularReferenceError, "Circular reference from #{symbol} to #{depend}" if stack.first == depend

          next if stack.include? depend

          stack << depend
          _walk(depend, stack, &block)
        rescue ::StopIteration
          return nil
        end

        yield(symbol) if block
      end

      def _register(symbol)
        @registry[symbol.to_s] || (@registry[symbol.to_s] = symbol)
      end

      def _register_by_meta(symbol_meta)
        _register Symbol.from_meta(symbol_meta)
      end

      def sanitize
        tap do
          @registry.each_value { |symbol| walk(symbol) }
        end
      end
    end
  end
end

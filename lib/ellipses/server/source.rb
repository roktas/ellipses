# frozen_string_literal: true

require "set"

module Ellipses
  module Server
    class Source
      attr_reader :symbols, :global, :root

      def initialize(symbols:, global:, directory:)
        @symbols   = symbols
        @global    = global
        @root      = global.root ? ::File.join(directory, global.root) : directory
        @consumed  = Set.new
      end

      def [](string)
        (chunks = []).tap do
          symbols.resolve(string).each { |symbol| yield_symbol(chunks, symbol) }
        end
      end

      private

      def yield_symbol(chunks, symbol)
        return if @consumed.include? symbol

        @consumed << symbol
        return if (lines = symbol.payload(root, global.extension)).empty?

        chunks << lines
      end

      class << self
        def load(directory)
          meta = (meta_file = MetaFile.new(directory)).read
          new symbols: Symbols.new(meta.symbols), global: meta.global, directory: meta_file.directory
        end
      end
    end
  end
end

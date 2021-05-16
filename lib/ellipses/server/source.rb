# frozen_string_literal: true

require "set"

module Ellipses
  module Server
    class Source
      attr_reader :symbols, :global, :directory

      def initialize(symbols:, global:, directory:, consumed: [])
        @symbols   = symbols
        @global    = global
        @directory = directory
        @consumed  = Set.new consumed
      end

      def [](string)
        [].tap do |chunks|
          symbols.resolve(string).each do |symbol|
            next if @consumed.include? symbol

            @consumed << symbol
            next if (lines = symbol.payload(root, global.extension)).empty?

            chunks << lines
          end
        end
      end

      private

      def root
        @root ||= global.root ? ::File.join(directory, global.root) : directory
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

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
            next if (lines = payload(symbol)).empty?

            chunks << lines
          end
        end
      end

      private

      def payload(symbol)
        return [] unless (file = where(symbol)) && !::File.directory?(file)

        ::File.readlines file
      end

      def root
        @root ||= global.root ? ::File.join(directory, global.root) : directory
      end

      def where(symbol)
        return ::File.exist?(symbol.path) ? ::File.join(root, symbol.path) : nil if symbol.path

        paths = [base = ::File.join(root, symbol.to_s)]
        paths.prepend("#{base}#{global.extension}") if global.extension

        paths.find { |path| ::File.exist?(path) }
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

# frozen_string_literal: true

require "forwardable"

module Ellipses
  module Server
    class Meta
      Error = Class.new Error

      using Support::Struct

      Global = Struct.new(:depends, :extension, :root, keyword_init: true) do
        def self.from_hash(hash)
          from_hash_without_bogus_keys!(hash, error: Error)
        end
      end

      Symbol = Struct.new(:symbol, :description, :path, :depends, keyword_init: true) do
        def to_s
          symbol
        end

        def add_depends(*depends)
          return if depends&.empty?

          self.depends ||= []
          depends.reverse_each { |member| self.depends.unshift(member) }
        end

        def self.from_hash(hash)
          from_hash_without_bogus_keys!(hash, error: Error)
        end

        def self.from_hash_with_depends(hash, *depends)
          from_hash_without_bogus_keys!(hash, error: Error).tap { |symbol| symbol.add_depends(*depends) }
        end
      end

      class Symbols
        extend Forwardable

        def_delegators :@symbols, :each, :length

        attr_reader :symbols

        def initialize(symbols, *depends)
          hash = {}

          (symbols || []).each do |meta|
            symbol = Symbol.from_hash_with_depends(meta, *depends)
            hash[symbol.to_s] = symbol
          end

          @symbols = hash.values
        end
      end

      attr_reader :symbols, :global

      def initialize(hash)
        symbols_array = hash.delete("symbols") || []
        global_hash   = hash || {}

        @global  = Global.from_hash(global_hash)
        @symbols = Symbols.new(symbols_array, *(@global.depends || []))
      end
    end
  end
end

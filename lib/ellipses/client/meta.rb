# frozen_string_literal: true

require "delegate"

module Ellipses
  module Client
    class Meta < SimpleDelegator
      Error = Class.new Error

      using Support::Struct

      Source = Struct.new :source, :series, keyword_init: true do
        def to_json(*args)
          to_h.to_json(*args)
        end

        def self.from_hash(hash)
          new source: hash[:source], series: Series.from_array(hash[:series])
        end
      end

      class Series < SimpleDelegator
        def initialize(array_of_locks)
          super

          @delegate_sd_obj = array_of_locks
        end

        def to_json(*args)
          to_a.to_json(*args)
        end

        def self.from_array(array_of_hashes)
          array_of_locks = array_of_hashes.map { |hash| Lock.from_hash hash }
          new array_of_locks
        end
      end

      Lock = Struct.new :directive, :insertion, keyword_init: true do
        def to_json(*args)
          to_h.to_json(*args)
        end

        def self.from_hash(hash)
          new directive: hash[:directive], insertion: Insertion.from_hash(hash[:insertion])
        end
      end

      Insertion = Struct.new :before, :after, :signature, :digest, keyword_init: true do
        def to_s
          signature
        end

        def to_json(*args)
          to_h.to_json(*args)
        end

        def self.from_hash(hash)
          new(**hash)
        end
      end

      def initialize(array_of_sources)
        super

        @delegate_sd_obj = array_of_sources
      end

      def to_json(*args)
        to_a.to_json(*args)
      end

      def self.from_array(array_of_hashes)
        array_of_sources = array_of_hashes.map { |hash| Source.from_hash(hash) }
        new array_of_sources
      end
    end
  end
end

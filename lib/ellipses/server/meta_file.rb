# frozen_string_literal: true

require 'tomlrb'

module Ellipses
  module Server
    class MetaFile
      FILE = 'src.toml'

      Error = Class.new(Error)

      attr_reader :directory

      def initialize(directory)
        @directory = Support.dir!(directory, error: Error)
        @file      = Support.file!(FILE, base: @directory, error: Error)
      end

      def to_s
        @file
      end

      def read
        Meta.new Tomlrb.load_file(@file)
      rescue StandardError => e
        raise Error, "Error while loading meta file: #{file}: #{e.message}"
      end

      class << self
        def valid?(directory)
          new(directory)
          true
        rescue Error
          false
        end
      end
    end
  end
end

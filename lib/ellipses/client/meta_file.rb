# frozen_string_literal: true

require "json"

module Ellipses
  module Client
    class MetaFile
      ALTERNATIVES = %w[.local/var/src.lock src.lock .src.lock].freeze
      EMPTY        = "[]\n"

      attr_reader :directory, :alternatives

      def initialize(directory, alternatives = nil)
        @directory    = directory
        @alternatives = alternatives || ALTERNATIVES
      end

      def file
        @file ||= begin
          base = alternatives.find do |file|
            ::File.directory?(::File.join(directory, File.dirname(file)))
          end
          raise Error, "Unable to locate lockfile" unless base

          ::File.join(directory, base)
        end
      end

      def to_s
        file
      end

      def touch
        ::File.write(file, EMPTY) unless ::File.exist? file
      end

      def exist?
        ::File.exist? file
      end

      def read
        Meta.from_array JSON.load_file(file, symbolize_names: true)
      end

      def write(meta)
        Support.updatelines(file, meta.empty? ? EMPTY : JSON.pretty_generate(meta))
      end
    end
  end
end

# frozen_string_literal: true

require 'json'

module Ellipses
  module Client
    class MetaFile
      FILES = %w[.local/var/src.lock src.lock .src.lock].freeze
      EMPTY = "[]\n"

      def self.create(directory)
        Support.dir!(directory)

        selected = FILES.find { |path| ::Dir.exist? File.join(directory, ::File.dirname(path)) }
        file     = ::File.join(directory, selected)

        ::File.write(file, EMPTY) unless ::File.exist? file

        new
      end

      attr_reader :directory, :alternatives

      def initialize
        @directory, @file = Support.search_path FILES
      end

      def file
        loaded!
        @file
      end

      def loaded?
        @file && ::File.exist?(@file)
      end

      def loaded!
        raise 'Lockfile not located' if @file.nil?

        raise "Lockfile not found: #{@file}" unless ::File.exist? @file
      end

      def read
        Meta.from_array JSON.load_file(file, symbolize_names: true)
      end

      def write(meta)
        Support.updatelines(file, meta.empty? ? EMPTY : JSON.pretty_generate(meta))
      end

      def to_s
        file
      end
    end
  end
end

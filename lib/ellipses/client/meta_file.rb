# frozen_string_literal: true

require 'json'

module Ellipses
  module Client
    class MetaFile
      EMPTY = "[]\n"

      def self.create(directory, alternatives)
        Support.dir!(directory)

        selected = alternatives.find { |path| ::Dir.exist? File.join(directory, ::File.dirname(path)) }
        file     = ::File.join(directory, selected)

        ::File.write(file, EMPTY) unless ::File.exist? file

        new alternatives
      end

      attr_reader :directory, :alternatives

      def initialize(alternatives)
        @alternatives = alternatives

        load
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

      private

      def load
        @directory, @file = Support.search_path alternatives
      end
    end
  end
end

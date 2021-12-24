# frozen_string_literal: true

require 'ellipses/server'

module Ellipses
  module Client
    class Source
      attr_reader :series, :server

      def initialize(lines, series, server)
        @lines  = lines
        @series = series || []
        @server = server
      end

      def lines
        @lines.is_a?(Lines) ? @lines : (@lines = Lines.new @lines.to_a)
      end

      def decompile
        return if series.empty?

        while (lock = series.shift)
          lines.substitute_uniq_like_chunk!(lock.insertion, lock.directive)
        end
      end

      def compile
        new_lines = Lines[]

        lines.each do |line|
          new_lines.append(*(Parser.match?(line) ? execute_and_record(line) : line))
        end

        @lines = new_lines
      end

      def recompile
        decompile
        compile
      end

      private

      def execute(line, **kwargs)
        raise Error, "No directive found: #{line}" unless (parsed = Parser.parse(line))

        directive = Directive.new(parsed.lexemes, server)

        outlines = directive.execute(**kwargs)
        outlines.map! { |outline| Support.prefixize_non_blank(outline, parsed.prefix, excludes: "\f\f\f") }

        Lines[outlines]
      end

      def execute_and_record(line, **kwargs)
        result = execute(line, **kwargs)
        series << Meta::Lock.new(directive: line, insertion: result.insertion_by_entropy)
        result
      end

      class << self
        def from_file(file, paths, series = nil)
          lines = File.readlines(Support.file!(file, error: Error)).lazy
          new lines, series, Server::Application.new(paths)
        end
      end
    end
  end
end

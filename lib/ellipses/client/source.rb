# frozen_string_literal: true

require 'ellipses/server'

module Ellipses
  module Client
    class Source
      attr_reader :series

      def initialize(lines, series)
        @lines        = lines
        @series       = series || []
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

      def compile(server)
        new_lines = Lines[]

        lines.each do |line|
          new_lines.append(*(Parser.match?(line) ? execute_and_record(line, server) : line))
        end

        @lines = new_lines
      end

      def recompile(server)
        decompile
        compile(server)
      end

      private

      def execute(line, server, **kwargs)
        raise Error, "No directive found: #{line}" unless (parsed = Parser.parse(line))

        directive = Directive.new(parsed.lexemes, server)

        outlines = directive.execute(**kwargs)
        outlines.map! { |outline| Support.prefixize_non_blank(outline, parsed.prefix, excludes: "\f\f\f") }

        Lines[outlines]
      end

      def execute_and_record(line, server, **kwargs)
        result = execute(line, server, **kwargs)
        series << Meta::Lock.new(directive: line, insertion: result.insertion_by_entropy)
        result
      end

      class << self
        def from_file(file, series = nil)
          lines = File.readlines(Support.file!(file, error: Error)).lazy
          new lines, series
        end
      end
    end
  end
end

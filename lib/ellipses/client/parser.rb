# frozen_string_literal: true

require 'shellwords'

module Ellipses
  module Client
    class Parser
      PATTERN = /
        ^
        (?<prefix>\s*)
        (?<directive>(?:[.]|>){3,}.*)
      /x

      Parsed = Struct.new :lexemes, :prefix, keyword_init: true do
        def to_a
          lexemes
        end
      end

      Lexeme = Struct.new :token, :argv, keyword_init: true do
        def self.from_strings(strings)
          new token: strings.shift.downcase, argv: strings
        end

        def to_s
          token
        end
      end

      class << self
        def parse(line)
          return unless (match = line.match(PATTERN))

          parser = new(match[:directive])

          Parsed.new lexemes: parser.(), prefix: match[:prefix]
        end

        def match?(line)
          !line.match(PATTERN).nil?
        end

        private_class_method :new
      end

      attr_reader :line

      def initialize(line)
        @line = line
      end

      def call
        groups = Shellwords.split(preprocess(line)).slice_after('|').map do |group|
          group.pop if group.last == '|'
          group
        end

        groups.map { |group| Lexeme.from_strings(group) }
      end

      private

      SUBSTITUTIONS = {
        /^[.]{3,}/ => 'include',
        /^>{3,}/   => ''
      }.freeze

      def preprocess(rawline)
        rawline.strip.tap do |line|
          SUBSTITUTIONS.each { |pattern, replace| line.gsub!(pattern, replace) }
          line.strip!
        end
      end
    end
  end
end

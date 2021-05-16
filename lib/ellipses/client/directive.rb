# frozen_string_literal: true

module Ellipses
  module Client
    class Directive
      Error = Class.new Error

      attr_reader :commands, :server

      def initialize(lexemes, server)
        @server   = server
        @commands = build(lexemes)
      end

      def execute(**kwargs)
        output = []
        commands.each do |command|
          output = command.call(input = output, **kwargs) || input
        end
        output
      end

      private

      def build(lexemes)
        lexemes.map do |lexeme|
          name = lexeme.token

          raise Error, "No such command available: #{name}" unless Commands.available?(name)

          proto = Commands.proto(name)
          raise Error, "Wrong number of arguments: #{lexeme.argv}" unless proto.valid?(lexeme.argv)

          proto.klass.new(lexeme.argv, server)
        end
      end
    end
  end
end

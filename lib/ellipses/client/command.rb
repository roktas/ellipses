# frozen_string_literal: true

require "ostruct"

module Ellipses
  module Client
    class Command
      Error = Class.new Error

      using Support::Refinements::Struct

      Proto = Struct.new :name, :klass, :argc, keyword_init: true do
        def valid?(argv)
          argc.nil? || argc.cover?(argv.size)
        end
      end

      module DSL
        def command(name, argc: (0..))
          Commands.register name, Proto.new(name: name, klass: self, argc: Support.to_range(argc))
        end
      end

      module Mixins
        module SetupPattern
          def patternize(arg = nil)
            param.pattern = Regexp.new(arg || argv.first)
          rescue RegexpError => e
            error(e.message)
          end

          def setup
            patternize
          end
        end
      end

      extend DSL

      attr_reader :argv, :server

      def initialize(argv, server)
        @argv   = argv
        @server = server
        @param  = OpenStruct.new

        setup
      end

      def setup; end

      def call(input, **kwargs)
        raise NotImplementedError
      end

      def error(*args)
        raise Error, *args
      end

      def to_s
        self.class.name.downcase
      end

      protected

      attr_reader :param
    end
  end
end

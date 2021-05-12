# frozen_string_literal: true

require_relative '../test_helper'

module Ellipses
  module Server
    class SymbolsTest < Minitest::Test
      def test_circular_reference
        hash = {
          'symbols' => [
            {
              'symbol'  => 'a',
              'depends' => %w[b c]
            },
            {
              'symbol'  => 'b'
            },
            {
              'symbol'  => 'c',
              'depends' => %w[a]
            }
          ]
        }
        assert_raises Symbols::CircularReferenceError do
          Symbols.new Meta.new(hash).symbols
        end
      end
    end
  end
end

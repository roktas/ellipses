# frozen_string_literal: true

require_relative "../test_helper"

module Ellipses
  module Client
    class LinesTest < Minitest::Test
      def test_ambiguous_chunks_error
        lines = Lines[%w[0 1 2 a 4 5 2 a 4 9]]
        insertion = Meta::Insertion.new before: 1, after: 1, signature: "a", digest: Support.digest(*%w[2 a 4])
        assert_raises AmbiguousError do
          lines.substitute_uniq_like_chunk!(insertion, "foo")
        end
      end
    end
  end
end

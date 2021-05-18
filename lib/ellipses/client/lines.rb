# frozen_string_literal: true

require 'delegate'

module Ellipses
  module Client
    class Lines < SimpleDelegator
      Surround = Struct.new :before, :after, keyword_init: true do
        def range(i)
          Range.new(i - before, i + after)
        end

        def center
          before
        end

        def sensible?(i)
          before <= i || after >= i
        end

        def sensible!(i)
          return true if sensible?(i)

          raise ArgumentError, "Insensible index #{i} for surround: #{before}, #{after}"
        end

        def length
          @length ||= before + after + 1
        end
      end

      private_constant :Surround

      class Chunk
        attr_reader :content, :center, :origin

        def initialize(content, center:, origin:)
          @content = content
          @center  = center
          @origin  = origin

          raise ArgumentError, "Invalid center of array: #{center}" unless center < content.length
        end

        def insertion
          @insertion ||= Meta::Insertion.new before:    center,
                                             after:     content.length - center - 1,
                                             signature: content[center],
                                             digest:    Support.digest(*content)
        end

        def size
          content.size
        end

        def origin_range
          (origin...(origin + size))
        end

        def to_a
          content
        end
      end

      private_constant :Chunk

      def initialize(array_of_lines)
        super

        @delegate_sd_obj = array_of_lines
      end

      def surrounding_chunk(i, before: 0, after: 0)
        return unless i < length

        range = (surround = Surround.new(before: before, after: after)).range(i)
        Chunk.new self[range], center: surround.center, origin: range.begin
      end

      def insertion_by_surround(i, before: 0, after: 0)
        return unless i < length

        signature = self[i]
        digest    = Support.digest(*self[Surround.new(before: before, after: after).range(i)])

        Meta::Insertion.new before: before, after: after, signature: signature, digest: digest
      end

      def insertion_by_entropy
        return if empty?

        signature = self[center = index_of_maximum_entropy]
        before    = center
        after     = length - center - 1
        digest    = Support.digest(*self)

        Meta::Insertion.new before: before, after: after, signature: signature, digest: digest
      end

      def likes(insertion)
        likes = []

        each_with_index do |line, i|
          next unless line == insertion.signature
          next unless (chunk = surrounding_chunk(i, before: insertion.before, after: insertion.after))
          next unless chunk.insertion == insertion

          likes << chunk
        end

        likes
      end

      def uniq_like_chunk!(insertion)
        raise UnfoundError,   "No chunks found like: #{insertion}"       if likes(insertion).empty?
        raise AmbiguousError, "Multiple chunks found like: #{insertion}" unless (likes = likes(insertion)).size == 1

        likes.first
      end

      def substitute_uniq_like_chunk!(insertion, *lines)
        uniq_like_chunk!(insertion).tap do |chunk|
          substitute_within(chunk.origin_range, *lines)
        end
      end

      private

      def index_of_maximum_entropy
        each_index.max_by { |i| Support.entropy(self[i]) }
      end

      def substitute_at(index, *lines)
        slice!(index).tap { insert(index, *lines) }
      end

      def substitute_within(index_or_range, *lines)
        slice!(range = Support.to_range(index_or_range)).tap { insert(range.begin, *lines) }
      end

      class << self
        def [](object = nil)
          case object
          when self       then object
          when Array      then new(object)
          when Enumerator then new(object.to_a)
          when NilClass   then new([])
          else                 new([*object])
          end
        end
      end
    end
  end
end

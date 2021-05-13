# frozen_string_literal: true

require "json"

module Ellipses
  module Client
    class LockFile
      FILES = %w[.local/var/src.lock src.lock .src.lock].freeze
      EMPTY = "[]\n"

      attr_reader :rootdir, :lockfiles

      def initialize(rootdir, lockfiles = nil)
        @rootdir   = rootdir
        @lockfiles = lockfiles || FILES
      end

      def lockfile
        @lockfile ||= begin
          base = lockfiles.find do |file|
            ::File.directory?(::File.join(rootdir, File.dirname(file)))
          end
          raise Error, "Unable to locate lockfile" unless base

          ::File.join(rootdir, base)
        end
      end

      def to_s
        lockfile
      end

      def touch
        ::File.write(lockfile, EMPTY) unless ::File.exist? lockfile
      end

      def exist?
        ::File.exist? lockfile
      end

      def read
        Meta.from_array JSON.load_file(lockfile, symbolize_names: true)
      end

      def write(meta)
        Support.update_file(lockfile, meta.empty? ? EMPTY : JSON.pretty_generate(meta))
      end
    end
  end
end

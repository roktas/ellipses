# frozen_string_literal: true

module Ellipses
  module Support
    class PathSanitizer
      def self.sanitize(*args, **kwargs)
        new(*args, **kwargs).sanitize
      end

      class Error < StandardError
        def initialize(path)
          super("#{kind}: #{path}")
        end

        def self.kind(message)
          Class.new self do
            define_method(:kind) { message }
          end
        end
      end

      MissingBase   = Error.kind "Directory not found"
      WrongBase     = Error.kind "Not a directory"
      MissingPath   = Error.kind "File or directory not found"
      NotFile       = Error.kind "Not a file"
      NotDir        = Error.kind "Not a directory"
      NotExecutable = Error.kind "Not an executable"

      attr_reader :path, :base, :fullpath

      def initialize(path:, base: nil)
        @path     = ::File.join(*path)
        @base     = ::File.join(*base) if base
        @fullpath = ::File.expand_path(@path, @base)
      end

      def sanitize
        if base
          raise MissingBase, base unless ::File.exist?(base)
          raise WrongBase,   base unless ::File.directory?(base)
        end

        raise MissingPath, fullpath unless ::File.exist?(fullpath)

        call

        fullpath
      end

      class Dir < PathSanitizer
        def call
          raise NotDir, fullpath unless ::File.directory?(fullpath)
        end
      end

      private_constant :Dir

      class File < PathSanitizer
        def call
          raise NotFile, fullpath unless ::File.file?(fullpath)
        end
      end

      private_constant :File

      class Executable < PathSanitizer
        def call
          raise NotExecutable, fullpath unless ::File.file?(fullpath) || ::File.executable?(fullpath)
        end
      end

      private_constant :Executable
    end

    private_constant :PathSanitizer

    module_function

    %i[file dir executable].each do |meth|
      klass = PathSanitizer.const_get meth.capitalize

      define_method(meth) do |path, base: nil|
        klass.sanitize(path: path, base: base)
      rescue PathSanitizer::Error
        nil
      end

      define_method("#{meth}!") do |path, error: nil, base: nil|
        klass.sanitize(path: path, base: base)
      rescue PathSanitizer::Error => e
        error ? raise(error, e.message) : raise
      end
    end
  end
end

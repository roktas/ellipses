# frozen_string_literal: true

module Foo
  module Support
    module File
      module_function

      def path(path, base: nil, error: nil)
        path, base = ::File.join(*path), base ? ::File.join(*base) : '.' # Quotations must have been escaped here -> ""

        status = if ::File.directory?(base)
                   result = ::File.expand_path(path, base)
                   if ::File.exist?(result)
                     yield(result) if block_given?

                     "File or directory not readable: #{result}" unless ::File.readable?(result)
                   else
                     "No such file or directory: #{result}"
                   end
                 else
                   "No such directory: #{base}"
                 end

        return Pathname.new(result).cleanpath.to_s unless status

        raise error, status if error

        nil
      end

      def file(file, base: nil, error: nil)
        path(file, base: base, error: error) do |result|
          "Not a file: #{result}" unless ::File.file?(result)
        end
      end

      def file!(file, error:, base: nil)
        file(file, error: error, base: base)
      end

      def dir(dir, base: nil, error: nil)
        path(dir, base: base, error: error) do |result|
          "Not a directory: #{result}" unless ::File.directory?(result)
        end
      end

      def dir!(dir, error:, base: nil)
        dir(dir, error: error, base: base)
      end
    end
  end
end

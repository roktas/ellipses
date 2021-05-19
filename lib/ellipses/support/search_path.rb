# frozen_string_literal: true

require 'pathname'

module Ellipses
  module Support
    module_function

    def search_path(patterns, starting_dir = '.')
      Pathname.new(starting_dir).expand_path.ascend.each do |dir|
        [*patterns].each do |pattern|
          next unless ::File.exist?(file = ::File.join(dir, pattern))

          return [dir.to_s, file]
        end
      end
    end
  end
end

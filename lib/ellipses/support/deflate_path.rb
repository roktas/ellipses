# frozen_string_literal: true

require "pathname"

module Ellipses
  module Support
    module_function

    def deflate_path(path, rootdir = nil)
      base = Pathname.new(rootdir || ".").expand_path
      Pathname.new(path).cleanpath.expand_path.relative_path_from(base).to_s
    end
  end
end

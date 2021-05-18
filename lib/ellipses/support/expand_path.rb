# frozen_string_literal: true

require 'pathname'

module Ellipses
  module Support
    module_function

    def expand_path(path, rootdir = nil)
      Pathname.new(::File.join(rootdir || '.', path)).cleanpath.to_s
    end
  end
end

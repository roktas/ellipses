# frozen_string_literal: true

module Ellipses
  module Client
    Error = Class.new Ellipses::Error

    AmbiguousError = Class.new Error
    UnfoundError   = Class.new Error
  end
end

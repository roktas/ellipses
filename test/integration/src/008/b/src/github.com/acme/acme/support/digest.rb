module Support
  module_function

  def digest(*args)
    ::Digest::SHA256.hexdigest args.map(&:to_s).join
  end
end

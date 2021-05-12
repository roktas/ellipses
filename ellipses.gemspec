# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'ellipses/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'ellipses'
  s.version     = Ellipses::VERSION
  s.summary     = 'Ellipses'
  s.description = 'Ellipses'

  s.required_ruby_version = '>= 2.5.0'

  s.license = 'GPL'

  s.author   = 'Recai Oktaş'
  s.email    = 'roktas@gmail.com'

  s.executables = Dir['bin/*']
  s.files       = Dir['lib/**/*']
  s.test_files  = Dir['test/**/*']

  s.add_dependency 'dry-cli'
  s.add_dependency 'tomlrb'

  s.add_development_dependency 'minitest-focus', '~> 0'
  s.add_development_dependency 'minitest-reportes', '~> 0'
end

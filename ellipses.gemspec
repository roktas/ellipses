# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'ellipses/version'

Gem::Specification.new do |s|
  s.name        = 'ellipses'
  s.author      = 'Recai Oktaş'
  s.email       = 'roktas@gmail.com'
  s.license     = 'GPL'
  s.version     = Ellipses::VERSION.dup
  s.summary     = 'Ellipses'
  s.description = 'Ellipses'

  s.homepage      = 'https://roktas.github.io/ellipses'
  s.files         = Dir['CHANGELOG.md', 'LICENSE.md', 'README.md', 'BENİOKU.md', 'ellipses.gemspec', 'lib/**/*']
  s.bindir        = 'bin'
  s.executables   = Dir['bin/*']
  s.require_paths = ['lib']

  s.metadata['allowed_push_host'] = 'https://rubygems.org'
  s.metadata['changelog_uri']     = 'https://github.com/roktas/ellipses/blob/master/CHANGELOG.md'
  s.metadata['source_code_uri']   = 'https://github.com/roktas/ellipses'
  s.metadata['bug_tracker_uri']   = 'https://github.com/roktas/ellipses/issues'

  s.required_ruby_version = '>= 2.5.0'

  s.add_dependency 'dry-cli'
  s.add_dependency 'tomlrb'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest-focus'
  s.add_development_dependency 'minitest-reportes'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
end

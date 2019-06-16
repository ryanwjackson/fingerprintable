# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fingerprintable/version'

Gem::Specification.new do |spec|
  spec.name          = 'fingerprintable'
  spec.version       = Fingerprintable::VERSION
  spec.authors       = ['Ryan Jackson']
  spec.email         = ['ryanwjackson@gmail.com']

  spec.summary       = 'Fingerprintable makes it easy to fingerprint an instance of any object.'
  spec.description   = 'Fingerprintable adds a way to fingerprint an instance of any object, with ability to easily add or ignore attributes.'
  spec.homepage      = 'https://www.github.com/ryanwjackson/fingerprintable'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mescal-cli/version'

Gem::Specification.new do |spec|
  spec.name          = "mescal-cli"
  spec.version       = MescalCli::VERSION
  spec.authors       = ["Chris Kite"]
  spec.email         = ["chris@chriskite.com"]
  spec.summary       = %q{Mescal CLI}
  spec.homepage      = "http://github.com/chriskite/mescal-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "rest-client", "~> 1.8.0"
  spec.add_dependency "yajl-ruby", "~> 1.2.1"
  spec.add_dependency "multi_json", "~> 1.11.0"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hummer/client/version'

Gem::Specification.new do |spec|
  spec.name          = "hummer-client"
  spec.version       = Hummer::Client::VERSION
  spec.authors       = ["Evgeniy Shurmin "]
  spec.email         = ["eshurmin@gmail.com"]
  spec.description   = %q{Client for Hummer server}
  spec.summary       = %q{Client for Hummer server}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "terminal-table"
  spec.add_dependency "json"
  spec.add_dependency "mime-types", "<2.0"
  spec.add_dependency "rest-client"
end

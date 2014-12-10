# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'copywriter/version'

Gem::Specification.new do |spec|
  spec.name          = "copywriter"
  spec.version       = Copywriter::VERSION
  spec.authors       = ["Ryan Jacobs"]
  spec.email         = ["ryan.mjacobs@gmail.com"]
  spec.summary       = %q{Updates all of your copyrights on GitHub.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "ryanmjacobs.github.io/copywriter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

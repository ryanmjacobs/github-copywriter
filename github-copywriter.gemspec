# encoding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "github-copywriter/version"

Gem::Specification.new do |gem|
    gem.name          = "github-copywriter"
    gem.version       = Copywriter::VERSION
    gem.authors       = ["Ryan Jacobs"]
    gem.email         = ["ryan.mjacobs@gmail.com"]
    gem.summary       = %q{github-copywriter updates your copyrights... so you don't have to!}
    gem.description   = %q{github-copywriter scans through your repositories and updates any copyrights it finds.}
    gem.homepage      = "http://ryanmjacobs.github.io/github-copywriter"
    gem.license       = "MIT"

    gem.files         = `git ls-files -z`.split("\x0") - %w(test_repo_demo.gif)
    gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
    gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
    gem.require_paths = ["lib"]

    gem.required_ruby_version = ">= 1.9.2"

    gem.add_development_dependency "bundler", "~> 1.6"
    gem.add_development_dependency "rake",    "~> 10.0"
    gem.add_development_dependency "rspec",   "~> 3.1"

    gem.add_runtime_dependency "octokit",  "~> 3.7"
    gem.add_runtime_dependency "colorize", "~> 0.7"
    gem.add_runtime_dependency "highline", "~> 1.6"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'richcss/version'

Gem::Specification.new do |spec|
  spec.name          = "richcss"
  spec.version       = Richcss::VERSION
  spec.authors       = ["Nicholas Lo, Gabriel Cheng, Bill Xu, Jonathan Lai, David Zhu"]
  spec.email         = ["richcssa4@gmail.com"]

  spec.summary       = %q{This is a command line package manager for the RichCSS framework}
  spec.homepage      = "https://github.com/fdp-A4/richcss-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "thor"
  spec.add_dependency "molinillo"
  spec.add_dependency "rest-client"
  spec.add_dependency "zipruby"
  spec.add_dependency "email_validator"
end

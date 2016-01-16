# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'richcss/version'

Gem::Specification.new do |spec|
  spec.name          = "richcss"
  spec.version       = Richcss::VERSION
  spec.authors       = ["Nicholas Lo, Gabriel Cheng, Bill Xu, Jonathan Lai"]
  spec.email         = ["nicholastclo@gmail.com"]

  spec.summary       = %q{This is a command line package manager for the Rich-css framework}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/bill-x/richcss-parts"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "thor"
  #spec.add_dependency "version_kit" # VersionKit is not published, thus its dependency will be added through bundler instead.
  spec.add_dependency "molinillo"
  spec.add_dependency "rest-client"
  spec.add_dependency "zipruby"
end

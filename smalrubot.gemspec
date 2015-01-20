# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smalrubot/version'

Gem::Specification.new do |spec|
  spec.name          = "smalrubot"
  spec.version       = Smalrubot::VERSION
  spec.authors       = ["Kouji Takao"]
  spec.email         = ["kouji.takao@gmail.com"]
  spec.summary       = %q{A library and an Arduino sketch for Smalruby.}
  spec.description   = %q{The smalrubot is a library and an Arduino sketch for Smalruby.}
  spec.homepage      = "https://github.com/smalruby/smalrubot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rubyserial'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end

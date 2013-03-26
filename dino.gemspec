# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dino/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Austinbv"]
  gem.email         = ["austinbv@gmail.com"]
  gem.description   = %q{A utility library for interfacting with an Arduino.
  Designed for control, expansion, and with love.}
  gem.summary       = %q{Control your arduino through a serial port}
  gem.homepage      = 'https://github.com/austinbv/dino'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dino"
  gem.require_paths = ["lib"]
  gem.version       = Dino::VERSION

  gem.add_dependency 'serialport'

  gem.add_development_dependency 'rake'
end

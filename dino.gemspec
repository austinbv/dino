# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dino/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Austinbv"]
  gem.email         = ["austinbv@gmail.com"]
  gem.description   = %q{A utility library for interfacting with an Arduino.
  Designed for control, expansion, and with love.}
  gem.summary       = %q{Control your Arduino with Ruby.}
  gem.homepage      = 'https://github.com/austinbv/dino'

  gem.files         = `git ls-files`.split($\)

  # Copy full submodule contents into the gem when building.
  # Credit:
  # https://gist.github.com/mattconnolly/5875987#file-gem-with-git-submodules-gemspec
  #
  # get an array of submodule dirs by executing 'pwd' inside each submodule
  gem_dir = File.expand_path(File.dirname(__FILE__)) + "/"
  `git submodule --quiet foreach pwd`.split($\).each do |submodule_path|
    Dir.chdir(submodule_path) do
      submodule_relative_path = submodule_path.sub gem_dir, ""
      # issue git ls-files in submodule's directory and
      # prepend the submodule path to create absolute file paths
      `git ls-files`.split($\).each do |filename|
        gem.files << "#{submodule_relative_path}/#{filename}"
      end
    end
  end

  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dino"
  gem.require_paths = ["lib"]
  gem.version       = Dino::VERSION
  gem.executables   = ["dino"]

  gem.add_dependency 'rubyserial', '~> 0.5.0'
  gem.add_dependency 'bcd', '~> 0.3.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end

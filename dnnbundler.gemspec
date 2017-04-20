# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dnnbundler/version'

Gem::Specification.new do |spec|
  spec.name          = "dnnbundler"
  spec.version       = Dnnbundler::VERSION
  spec.authors       = ["Le0Michine"]
  spec.email         = ["leomichine@gmail.com"]

  spec.summary       = %q{Creates zip packages for DNN.}
  spec.description   = %q{Creates zip packages with complex structure.}
  spec.homepage      = "https://github.com/Le0Michine/dnnbundler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "rubyzip"
  spec.add_dependency "json"
  spec.add_dependency "zipbundler"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end

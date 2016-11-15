# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sanger_barcode_format/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["James Glover"]
  gem.email         = ["jg16@sanger.ac.uk"]
  gem.description   = %q{Holds the sanger barcode model}
  gem.summary       = %q{Sanger Barcode Format}
  gem.homepage      = "http://www.sanger.ac.uk"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "sanger_barcode_format"
  gem.require_paths = ["lib"]
  gem.version       = SBCF::VERSION

  gem.add_development_dependency('rake','~>0.9.2.2')
  gem.add_development_dependency('rspec','~>2.11.0')
  gem.add_development_dependency('rubocop')
  gem.add_development_dependency('yard')
end
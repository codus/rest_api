# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rest_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Codus Tecnologia"]
  gem.email         = ["vinicius.oyama@codus.com.br"]
  gem.platform    = Gem::Platform::RUBY
  gem.description   = %q{An easy to use, no configuration API client!}
  gem.summary       = %q{An easy to use, no configuration API client!}
  gem.homepage      = "https://github.com/codus/rest_api"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rest_api"
  gem.require_paths = ["lib"]
  gem.version       = RestApi::VERSION


  gem.add_dependency('activesupport', '~> 3.2')
  gem.add_dependency('json', '~> 1.7')
  gem.add_dependency('rest-client', '~> 1.6')
end

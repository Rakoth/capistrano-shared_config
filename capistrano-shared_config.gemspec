# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/shared_config/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-shared_config'
  spec.version       = Capistrano::SharedConfig::VERSION
  spec.authors       = ['Alexander Stanko']
  spec.email         = ['rakoth3d@gmail.com']
  spec.description   = %q{This gem provides several capistrano tasks for config files uploading and symlinking during deploy}
  spec.summary       = %q{Config files management during capistrano deploy}
  spec.homepage      = 'https://github.com/Rakoth/capistrano-shared_config'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'capistrano', '~> 2.14'
  spec.add_development_dependency 'capistrano-spec'
  spec.add_development_dependency 'rspec', '~> 2.13'
end

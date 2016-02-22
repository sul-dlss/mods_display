# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mods_display/version'

Gem::Specification.new do |gem|
  gem.name          = 'mods_display'
  gem.version       = ModsDisplay::VERSION
  gem.authors       = ['Jessie Keck']
  gem.email         = ['jessie.keck@gmail.com']
  gem.description   = 'MODS Display is a gem to centralize the display logic of MODS medadata.'
  gem.summary       = 'The MODS Display gem allows implementers to configure a customized display of MODS metadata.  This display implements the specifications defined at Stanford for how to display MODS.'
  gem.homepage      = 'https://github.com/sul-dlss/mods_display'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'stanford-mods', '~> 2.1'
  gem.add_dependency 'i18n'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop'
end

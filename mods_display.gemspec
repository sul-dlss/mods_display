# frozen_string_literal: true
require_relative "lib/mods_display/version"

Gem::Specification.new do |gem|
  gem.name          = 'mods_display'
  gem.version       = ModsDisplay::VERSION
  gem.authors       = ['Jessie Keck']
  gem.email         = ['jessie.keck@gmail.com']
  gem.description   = 'MODS Display is a gem to centralize the display logic of MODS metadata.'
  gem.summary       = 'The MODS Display gem allows implementers to configure a customized display of MODS metadata.  This display implements the specifications defined at Stanford for how to display MODS.'
  gem.homepage      = 'https://github.com/sul-dlss/mods_display'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gem.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  gem.bindir = "exe"
  gem.executables = gem.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'stanford-mods', '~> 3.3', '>=3.3.8' # require stanford-mods 3.3.8 for publisher field
  gem.add_dependency 'i18n'
  gem.add_dependency 'view_component'
  gem.add_dependency 'rails_autolink'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'capybara'
  gem.add_development_dependency 'rails', ENV['RAILS_VERSION'] || '~> 6.0'
  gem.add_development_dependency 'combustion', '~> 1.3'
end

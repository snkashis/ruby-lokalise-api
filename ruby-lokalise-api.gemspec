require File.expand_path('lib/ruby-lokalise-api/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'ruby-lokalise-api'
  spec.version               = Lokalise::VERSION
  spec.authors               = ['Ilya Bodrov']
  spec.email                 = ['golosizpru@gmail.com']
  spec.summary               = 'Ruby interface to the Lokalise API'
  spec.description           = 'Opinionated Ruby client for the Lokalise platform API allowing to work with translations, projects, users and other resources as with Ruby objects.'
  spec.homepage              = 'https://github.com/lokalise/ruby-lokalise-api'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.4.0'

  spec.files = Dir['README.md', 'LICENSE',
                   'CHANGELOG.md', 'lib/**/*.rb', 'lib/ruby-lokalise-api/data/attributes.json',
                   'ruby-lokalise-api.gemspec', '.github/*.md',
                   'Gemfile', 'Rakefile']
  spec.test_files       = Dir['spec/**/*.rb']
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']

  spec.add_dependency 'addressable',                   '~> 2.5'
  spec.add_dependency 'faraday',                       '~> 0.13'

  spec.add_development_dependency 'dotenv',                    '~> 2.5'
  spec.add_development_dependency 'oj',                        '~> 3.8'
  spec.add_development_dependency 'rake',                      '~> 12.1'
  spec.add_development_dependency 'rspec',                     '~> 3.6'
  spec.add_development_dependency 'rubocop',                   '~> 0.60'
  spec.add_development_dependency 'rubocop-performance',       '~> 1.0'
  spec.add_development_dependency 'simplecov',                 '~> 0.16'
  spec.add_development_dependency 'vcr',                       '~> 5.0'
end

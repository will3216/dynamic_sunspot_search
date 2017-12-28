
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awesome_search/version'

Gem::Specification.new do |spec|
  spec.name          = 'awesome_search'
  spec.version       = AwesomeSearch::VERSION
  spec.authors       = ['Will Bryant']
  spec.email         = ['william@tout.com']

  spec.summary       = %q{Json query language for use with Solr and Ruby}
  spec.description   = %q{Json query language for use with Solr and Ruby}
  spec.homepage      = 'https://github.com/will3216/awesome_search'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-byebug'

  # for testing a gem with a rails app (controller specs)
  # https://codingdaily.wordpress.com/2011/01/14/test-a-gem-with-the-rails-3-stack/
  # spec.add_development_dependency 'bundler', '>= 0', '~> 1.16'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'listen', '>= 3.0.5', '< 3.2'
  spec.add_development_dependency 'sunspot_rails'
  spec.add_development_dependency 'sunspot_solr'
end

Gem::Specification.new do |s|
  s.name = 'active_presenter'
  s.version = '3.3.0'
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to?(:required_rubygems_version=)
  s.authors = ['James Golick', 'Daniel Haran', 'Josh Martin', 'Johnno Loggie', 'Cedric Darricau']
  s.date = '2012-03-26'
  s.extra_rdoc_files = [
    'LICENSE',
    'README.rdoc'
  ]
  s.files = [
    'LICENSE',
    'Gemfile',
    'README',
    'README.rdoc',
    'Rakefile',
    'TODO',
    'active_presenter.gemspec',
    'lib/active_presenter.rb',
    'lib/active_presenter/base.rb',
    'lib/active_presenter/version.rb',
    'lib/tasks/doc.rake',
    'lib/tasks/gem.rake',
    'test/test_helper.rb',
    'test/base_test.rb',
    'test/lint_test.rb'
  ]
  s.homepage = 'http://github.com/jamesgolick/active_presenter'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.rubygems_version = '1.3.7'
  s.summary = 'The presenter library you already know.'
  s.test_files = [
    'test/base_test.rb',
    'test/lint_test.rb',
    'test/test_helper.rb'
  ]
  s.add_runtime_dependency('activerecord', ['~> 5.1.0'])
  s.add_development_dependency('rake', ['>= 12.0'])
  s.add_development_dependency('rspec', ['>= 3.0.0'])
  s.add_development_dependency('sqlite3', ['>= 1.3.5'])
  s.add_development_dependency('simplecov', ['>= 0.15.0'])
end

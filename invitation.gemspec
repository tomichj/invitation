require 'English'
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'invitation/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'invitation'
  s.version     = Invitation::VERSION
  s.authors     = ['Justin Tomich']
  s.email       = ['justin@tomich.org']
  s.homepage    = 'http://github.com/tomichj/invitation'
  s.summary     = 'Allow users to invite other users to join your organization'
  s.description = 'Allow users to invite other users to join your organization'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 4.0', '< 6.0'

  s.add_development_dependency 'factory_girl', '~> 4.8'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'rspec-mocks', '~> 3.5'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'

  s.required_ruby_version = Gem::Requirement.new('>= 2.0')
end

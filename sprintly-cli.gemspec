require File.join([File.dirname(__FILE__),'lib','sprintly-cli_version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'sprintly-cli'
  s.version = SprintlyCli::VERSION

  s.author = 'Andrew Harrison'
  s.email = 'atharrison@gmail.com'
  s.homepage = 'http://rubydoc.info/atharrison/sprintly-cli'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A Command-line interface to Sprint.ly'
  #START:lib
  s.files = %w(
bin/sprintly-cli
lib/sprintly-cli_version.rb
  )
  #START_HIGHLIGHT
  s.require_paths << 'lib'
  #END_HIGHLIGHT
  #END:lib
  #s.has_rdoc = true
  #s.extra_rdoc_files = ['README.rdoc','todo.rdoc']
  #s.rdoc_options << '--title' << 'sprintly-cli' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = ''
  #s.bindir = 'bin'
  s.executables << 'sprintly-cli'
  #s.add_development_dependency('aruba', '~> 0.4.6')
  s.add_dependency('thor')
  s.add_dependency('require_all', '~> 1.2.1')
end

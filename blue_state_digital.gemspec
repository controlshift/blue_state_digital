Gem::Specification.new do |s|
  s.name        = 'blue_state_digital'
  s.version     = '1.0.0'
  s.author      = ['Nathan Woodhull', 'Frederic Lemay']
  s.email       = ''
  s.homepage    = 'https://github.com/controlshift/blue_state_digital'
  s.summary     = 'Simple wrapper for Blue State Digital.'
  s.description = ''

  s.files        = Dir['{lib,spec}/**/*', '[A-Z]*', 'init.rb'] - ['Gemfile.lock']
  s.require_path = 'lib'

  s.add_development_dependency 'rspec', '~> 2.9.0'

  s.rubyforge_project = s.name
  s.required_rubygems_version = '>= 1.3.4'
end

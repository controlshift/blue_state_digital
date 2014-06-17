# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "blue_state_digital/version"

Gem::Specification.new do |s|
  s.name        = "blue_state_digital"
  s.version     = BlueStateDigital::VERSION
  s.authors     = ["Nathan Woodhull", "Sean Ho"]
  s.email       = ["woodhull@gmail.com", "seanho@thoughtworks.com"]
  s.homepage    = "https://github.com/controlshift/blue_state_digital"
  s.summary     = "Simple wrapper for Blue State Digital."
  s.description = %q{Simple wrapper for Blue State Digital.}
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "timecop"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-debugger"
  s.add_development_dependency "rb-fsevent"
  s.add_dependency "activesupport"
  s.add_dependency "activemodel"
  s.add_dependency "faraday", '>= 0.8.9'
  s.add_dependency "builder"
  s.add_dependency "nokogiri"
  s.add_dependency "crack"
  s.add_dependency "hashie"
end

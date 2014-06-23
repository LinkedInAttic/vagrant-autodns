#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-autodns/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-autodns'
  spec.version       = VagrantAutoDNS::VERSION
  spec.authors       = ['Casey Abernathy', 'Omar Alaouf']
  spec.email         = ['casey.a@slideshare.com']
  spec.description   = 'Vagrant plugin for automagically managing guest DNS'
  spec.summary       = <<-SUMMARY.gsub(/\s+/, ' ').strip
      Vagrant plugin that uses a SQLite3 backed RubyDNS instance to manage vagrant
      guest VMs dns and domain settings
    SUMMARY
  spec.homepage      = 'https://github.com/SlideShareInc/vagrant-autodns'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.0.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'sqlite3', '~> 1.3.8'
  spec.add_runtime_dependency 'rubydns', '~> 0.7.0'
end

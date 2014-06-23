# Vagrant::Autodns

Vagrant plugin for automagically managing guest DNS. It uses a local DNS
daemon (RubyDNS) that stores DNS entries in a SQLite database.

It has been designed not to run as root. To be able to do that,
Vagrant::AutoDNS creates an iptable rule on your guest machine to do DNS
request forwardng between the 53 privileged port to the hosts 15353 unprivileged port.

##License

© 2014 LinkedIn Corp. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

##Requirements

You need sqlite3 gem and ruby 1.9.2 minimum to use this plugin

## Installation
###Simple Install:
```bash
    $ vagrant plugin install vagrant-autodns
```
###Bundler Install:
Add this to your application's Gemfile:
```bash
    $ cat > Gemfile <<EO_GEMFILE
    source 'https://rubygems.org'

    group :development do
      gem 'vagrant', git: 'https://github.com/mitchellh/vagrant.git'
    end

    group :plugins do
      gem 'vagrant-autodns', path: '.'
    end
    EO_GEMFILE
```

And then execute:
```bash
    $ bundle install
```
###Development install:
Or fork the vagrant-autodns code from: https://github.com/linkedin/vagrant-autodns
```bash
    $ git clone https://github.com/linkedin/vagrant-autodns
    $ cd autodns
    $ bundle install
    $ bundle exec gem build vagrant-autodns.gemspec
    $ sudo gem install --local vagrant-autodns-*.gem
    $ vagrant plugin install vagrant-autodns
    $ vagrant plugin list
```
## Usage

=======
Vagrant::AutoDNS runs automatically at machines creation. It starts the daemon
if not started and adds a the record the DNS database.

### Configuration

AutoDNS usage is configured in your Vagrantfile :

```ruby
    # Require the plugin for this Vagrant instance
    Vagrant.require_plugin 'vagrant-autodns'

    Vagrant.configure(2) do |config|
      # Enable the plugin for this config
      # Internal DNS
      config.autodns.enable
      config.vm.network 'private_network', type => 'dhcp'
    end
```
### CLI

Display help :
```bash
    $ vagrant autodns help
    Usage: vagrant autodns <command> [<args>]

    Available subcommands:
         add
         clear
         delete
         list
         reload_all
         restart
         start
         status
         stop

    For help on any individual command run `vagrant autodns COMMAND -h`
```
Daemon management :
```bash
    $ vagrant autodns {start|stop|restart|status}
```
Add a record manually :
```bash
    $ vagrant autodns add <hostname> <ip> [vagrant_id]
    $ vagrant autodns add test.vagrant.dev 1.2.3.4
```
List all DNS entries :
```bash
    $ vagrant autodns list
```
Clear the DNS entries :
```bash
    $ vagrant autodns clear
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

module VagrantAutoDNS
  class Plugin < Vagrant.plugin('2')

    name 'Vagrant Autodns'
    description <<-DESC.gsub(/\s+/, ' ').strip
      Autodns is a vagrant plugin that automatically sets up and maintains
      DNS records (with SQLite) for any dependent VMs via a built in RubyDNS server
    DESC

    config 'autodns' do
      require_relative 'config'
      Config
    end

    command 'autodns' do
      require_relative 'command'
      Command
    end

    action_hook 'autdns_up', :machine_action_up do |hook|
      #Find an available hook
      hook_action = nil
      [
        'VagrantPlugins::ProviderVirtualBox::Action::Network',
        'HashiCorp::VagrantVMwarefusion::Action::Network',
        'Vagrant::Action::Builtin::SetHostname',
      ].find{|x| hook_action = safe_constantize(x)}

      hook.before(hook_action, after_set_hostname)
    end

    action_hook 'autodns_destroy', :machine_action_destroy do |hook|
      hook.append(after_destroy)
    end

    guest_capability 'linux', 'get_ip' do
      require_relative './cap/get_ip'
      Cap::GetIP
    end

    guest_capability 'linux', 'install_iptables' do
      require_relative './cap/install_iptables'
      Cap::InstallIptables
    end

    guest_capability 'linux', 'redirect_dns' do
      require_relative './cap/redirect_dns'
      Cap::RedirectDNS
    end

    def self.after_set_hostname
      require_relative 'actions/start'
      require_relative 'actions/add'
      require_relative 'actions/redirect_dns'
      ::Vagrant::Action::Builder.new.tap do |builder|
        #Starts the AutoDNSDB Daemon
        builder.use Action::Start
        #Adds guest hostname records to AutoDNSDB
        builder.use Action::Add
        #Redirect guest DNS to daemon with IP tables
        builder.use Action::RedirectDNS
      end
    end

    def self.after_destroy
      require_relative 'actions/delete'
      require_relative 'actions/teardown'
      ::Vagrant::Action::Builder.new.tap do |builder|
        #Remove all hostname entries for guest
        builder.use Action::Delete
        #Shutdown daemon if not needed
        builder.use Action::Teardown
      end
    end

    private

    def self.safe_constantize(const_str)
      const_str.split('::').compact.inject(Object) do |parent_const, sub_const|
        parent_const.const_get(sub_const)
      end
    rescue NameError
      nil
    end
  end
end

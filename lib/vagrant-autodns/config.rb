#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

require_relative 'daemon'

module VagrantAutoDNS
  class Config < Vagrant.plugin('2', :config)

    # @return [Boolean]
    attr_accessor :enabled

    # @return [String, Array] (default System resolver)
    attr_accessor :resolver

    # @return [String] Valid IPV4 address (default 127.0.0.1)
    attr_accessor :listen_ip

    # @return [Fixnum] Port number (default 15353)
    attr_accessor :listen_port

    # @return [String] IPv6 address
    attr_accessor :listen_ipv6

    # @return [Boolean] Enable ipv6
    attr_accessor :enable_ipv6

    # @return [String] Directory to store data and state
    attr_accessor :working_directory

    # @return [String] DB File name
    attr_accessor :db_file

    DAEMON_DEFAULT_OPTS = {
      :working_directory => '.vagrant/autodns',
      :listen_ip => '127.0.0.1',
      :listen_port => 15353,
      :resolver => :system, #Deamon defaults to system
      :db_file => 'autodns.db',
      :enable_ipv6 => true,
    }

    CLIENT_DEFAULT_OPTS = {
      :aliases => []
    }

    DEFAULT_VALUES = {
      :enabled => false
    }.merge(DAEMON_DEFAULT_OPTS).merge(CLIENT_DEFAULT_OPTS)

    def initialize
      super
      DEFAULT_VALUES.keys.each do |default_key|
        instance_key = instance_var(default_key)
        instance_variable_set(instance_key, UNSET_VALUE)
      end
    end

    def alias(*aliases)
      @aliases.concat(aliases)
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end

    def enabled?
      #Coerce to boolean
      !!@enabled
    end

    def finalize!
      #special handling for working_directory
      expand_working_directory

      DEFAULT_VALUES.each do |default_key, default_value|
        instance_key = instance_var(default_key)
        if instance_variable_get(instance_key) == UNSET_VALUE
          instance_variable_set(instance_key, default_value)
        end
        next unless DAEMON_DEFAULT_OPTS.has_key?(default_key)
        Daemon.send(:instance_variable_set, instance_key, instance_variable_get(instance_key))
      end
    end

    private

    def expand_working_directory
      case @working_directory
      when UNSET_VALUE
        @working_directory = File.expand_path DAEMON_DEFAULT_OPTS[:working_directory]
      else
        @working_directory = File.expand_path working_directory
      end
    end

    def instance_var(key)
      '@' + key.to_s
    end
  end
end
#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

require 'rexec'
require 'rexec/daemon'
require 'rubydns'
require 'rubydns/resolver'
require 'rubydns/system'
require 'rainbow/ext/string'
require_relative 'autodnsdb'

module VagrantAutoDNS
  class Daemon < RExec::Daemon::Base

    @@base_directory = nil

    ProcessFile = RExec::Daemon::ProcessFile
    A_RECORD = Resolv::DNS::Resource::IN::A
    AAAA_RECORD = Resolv::DNS::Resource::IN::AAAA

    class << self
      attr_accessor :working_directory, :resolver, :db_file
      attr_accessor :listen_ip, :listen_port, :enable_ipv6
    end

    def self.run
      upstream = upstream_resolver
      db_lib = AutoDNSDB
      db_absolute_path = autodnsdb_path
      allow_ipv6 = ipv6_enabled?
      RubyDNS::run_server(:listen => listen_interface) do
        db = db_lib.new(db_absolute_path)
        match(//, A_RECORD) do |transaction|
          domain = transaction.name.to_s.encode('US-ASCII')
          record = db.find_record(domain)
          if record
            transaction.respond!(record['ip'])
          else
            transaction.passthrough!(upstream)
          end
        end

        match(//, AAAA_RECORD) do |transaction|
          if allow_ipv6
            transaction.passthrough!(upstream)
          else
            transaction.fail!(:NXDomain)
          end
        end

        # Default DNS handler
        otherwise do |transaction|
          transaction.passthrough!(upstream)
        end
      end
    end

    def self.restart
      stop unless stopped?
      start
    end

    def self.ensure_running
      restart unless running?
    end

    def self.daemon_status
      ProcessFile.status(self)
    end

    def self.pid
      ProcessFile.recall(self)
    end

    def self.running?
      daemon_status == :running
    end

    def self.stopped?
      daemon_status == :stopped
    end

    def self.ipv6_enabled?
      @enable_ipv6.nil? || @enable_ipv6
    end

    def self.autodnsdb
      return @autodnsdb if @autodnsdb.is_a?(AutoDNSDB)
      @autodnsdb = AutoDNSDB.new(autodnsdb_path)
    end

    def self.autodnsdb_path
      @autodnsdb_path ||= File.expand_path(File.join(working_directory, db_file))
    end

    def self.working_directory=(dir)
      @working_directory = File.expand_path(dir)
    end

    private

    # RubyDNS upstream resolver
    def self.upstream_resolver
      #Bail out if already set
      return @resolver if @resolver.is_a?(RubyDNS::Resolver)
      #Case statment must set new_resolver to a valid interface
      case @resolver
      when String
        # IP or IP/PORT combo
        new_resolver = to_interface(@resolver)
      when Array
        #If 2 strings are provided assume they are IPs
        if @resolver.length == 2 && @resolver.all?{|v| v.is_a? String}
          new_resolver = @resolver.map{|ip| to_interface(ip)}.flatten(1)
        #Else expect array formated in interface form
        else
          new_resolver = @resolver
        end
      when Symbol
        #Use the predefined custom_resolvers
        new_resolver = custom_resolver(@resolver)
      when NilClass
        #Default to system_resolver
        new_resolver = system_resolver
      end
      @resolver = RubyDNS::Resolver.new(new_resolver)
    end

    def self.listen_interface
      to_interface(listen_ip, listen_port)
    end

    def self.custom_resolver(resolver = :random)
      return system_resolver if resolver == :system
      #TODO: move to config file somewhere
      hosted_resolvers = {
        :level3 => ['209.244.0.3', '209.244.0.4'],
        :google => ['8.8.8.8', '8.8.4.4'],
        :securly => ['184.169.143.224', '184.169.161.155'],
        :comodo => ['8.26.56.26', '8.20.247.20'],
        :opendns => ['208.67.222.222', '208.67.220.220'],
        :norton => ['198.153.192.40', '198.153.194.40'],
        :opennic => ['216.87.84.211', '23.90.4.6']
      }
      resolver = hosted_resolvers.keys.sample if resolver == :random
      resolver_ip = hosted_resolvers[resolver]
      resolver_ip.map{|ip| to_interface(ip)}.flatten(1)
    end

    def self.system_resolver
      RubyDNS::System::nameservers
    end

    IPV4_6_PORT_REGEX = 
      /^(?:[0-9.]+|(?:\[[0-9a-fA-F:]+\]))(:[0-9]+)?$/

    def self.to_interface(ip, port = 53)
      #Try to extract IP and PORT from IP
      ip_r, port_r = ip.match(IPV4_6_PORT_REGEX).to_a
      #If regex found port, set it accordingly
      # remove preceding semi-colon
      port = port_r[1..-1].to_i if port_r
      [[:udp, ip_r, port], [:tcp, ip_r, port]]
    end
  end
end

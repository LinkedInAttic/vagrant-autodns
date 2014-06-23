#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

require_relative 'common'

module VagrantAutoDNS
  module Cap
    class RedirectDNS
      extend Cap::Common
      PRIVATE_IP = /^(192\.168|10\.|169\.254|172\.(1[6-9]|2\d|3[0-1]))/
      def self.redirect_dns(machine)
        #Get guest nameserver
        get_nameserver = [
          'grep nameserver /etc/resolv.conf',
          "awk '{print $2}'",
          'head -n1'
        ].join(' | ')
        nameserver = run_command(machine, get_nameserver)

        #Default to use resolvconf if installed
        update_search_domain = if !run_command(machine, 'command -v resolvconf').empty?
          [
            'echo "search $(hostname -d)" >> /etc/resolvconf/resolv.conf.d/base',
            'resolvconf -u'
          ].join(' && ')
        #Else check if dhclient is installed and try that
        elsif !run_command(machine, 'command -v dhclient').empty?
          #Find dhclient.conf location, consider doing this more intelligently
          dhclient_conf_loc = [
            '/etc/dhclient.conf',
            '/etc/dhcp/dhclient.conf',
            '/etc/dhcp3/dhclient.conf',
            #Dump to /dev/null if no conf can be found
            '/dev/null'
          ].map{|v| "ls #{v} 2>/dev/null"}.join(' || ')

          [
            "dhclient_conf_loc=$( #{dhclient_conf_loc} )",
            #Use dhclient to persist changes across reboots
            'echo "prepend domain-search $(hostname -d);" >> $dhclient_conf_loc',
            'sed "s/^search \(.*\)/search $(hostname -d) \1/" /etc/resolv.conf > /tmp/resolv.conf',
            'mv -f /tmp/resolv.conf /etc/resolv.conf'
          ].join(' && ')
        #Else overwrite resolv.conf directly
        else
          [
            'sed "s/^search \(.*\)/search $(hostname -d) \1/" /etc/resolv.conf > /tmp/resolv.conf',
            'mv -f /tmp/resolv.conf /etc/resolv.conf'
          ].join(' && ')
        end
        run_command(machine, update_search_domain)

        #Iptables redirect
        if nameserver =~ PRIVATE_IP
          daemon_port = Daemon.listen_port
          iptables_options_udp = [
            '-t nat', #Type nat
            '-A OUTPUT', #Append to output chain
            '-p udp', #Protocol udp (required to use dport)
            "-d #{nameserver}", #Destination ip
            '--dport 53', #Destination port
            '-j DNAT', #Target DNAT
            "--to-destination #{nameserver}:#{daemon_port}" #New destination
          ].join(' ')
          iptables_options_tcp = iptables_options_udp.gsub('-p udp', '-p tcp')
          run_command(machine, "#{iptables_location(machine)} #{iptables_options_udp}")
          run_command(machine, "#{iptables_location(machine)} #{iptables_options_tcp}")
        end
      end
    end
  end
end
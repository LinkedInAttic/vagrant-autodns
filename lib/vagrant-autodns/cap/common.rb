#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

module VagrantAutoDNS
  module Cap
    module Common
      #Run command on remote machine
      def run_command(machine, command, show_full_result = false)
        std_out = []
        std_err = []
        exit_code = machine.communicate.sudo(command, :error_check => false) do |type, data|
          next if data =~ /stdin: is not a tty/
          std_out << data if type == :stdout
          std_err << data if type == :stderr
        end
        full_result = {
          :exit_code => exit_code,
          :stdout => std_out.join.strip,
          :stderr => std_err.join.strip
        }
        show_full_result ? full_result : full_result[:stdout]
      end
      #Get iptables bin location
      def iptables_location(machine)
        iptables_location = [
          'iptables',
          '/bin/iptables',
          '/sbin/iptables',
          '/usr/bin/iptables',
          '/usr/sbin/iptables'
        ].map{|l| "command -v #{l}"}.join(' || ')
        run_command(machine, iptables_location)
      end
    end
  end
end 
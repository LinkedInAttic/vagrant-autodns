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
    class GetIP
      extend Cap::Common
      def self.get_ip(machine)
        #Multi-lined and joined with pipes for readability
        command = [
          '/sbin/ifconfig -a', #Prints ifconfig
          'grep inet', #Get ip address lines only
          'grep -v \'127.0.0.1\'', #Remove localhost
          'grep -Eo \'[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*\'', #match IPv4 line
          'awk \'{print $1}\'',
          'tail -n1' #Pick last
        ].join(' | ')
        run_command(machine, command)
      end
    end
  end
end 
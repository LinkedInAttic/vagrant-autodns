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
    class InstallIptables
      extend Cap::Common
      #Flags to install packages on various linux platforms
      INSTALL_FLAG = {
        'apt-get' => 'install -y',
        'aptitude' => 'install -y',
        'yum' => 'install -y',
        'pacman' => '-S --noconfirm',
        'zypper' => 'install --noconfirm',
        'apt-rpm' => 'install -y',
      }
      def self.install_iptables(machine)
        if iptables_location(machine).empty?
          #Get package manager
          pm_type = INSTALL_FLAG.keys.map{|p| "command -v #{p}"}.join(' || ')
          package_manager = run_command(machine, pm_type)
          #Install iptables
          install_flag = INSTALL_FLAG[package_manager[/[^\/]+$/]]
          run_command(machine, "#{package_manager} #{install_flag} iptables")
        end
      end
    end
  end
end
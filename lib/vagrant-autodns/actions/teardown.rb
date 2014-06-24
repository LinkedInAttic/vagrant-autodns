#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

require_relative '../action'

module VagrantAutoDNS
  module Action
    class Teardown
      include Common
      def action
        require_relative '../daemon'
        if VagrantAutoDNS.autodnsdb.dependent_vms.empty? and VagrantAutoDNS::Daemon.running?
          log.info('Stopping AutoDNS Daemon')
          VagrantAutoDNS::Daemon.stop
        end
      end
    end
  end
end

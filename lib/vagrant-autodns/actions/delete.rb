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
    class Delete
      include Common
      def action
        require_relative '../autodnsdb'
        log.info("Deleting DNS records for host #{machine_name}")
        if VagrantAutoDNS.autodnsdb.delete_host(machine_name)
          log.info("Entries for host #{machine_name} has been removed")
        else
          log.error("Failed to remov record for #{machine_name}")
        end
      end
    end
  end
end

#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

module VagrantAutoDNS
  class Command
    class Add < Vagrant.plugin("2", :command)

      def execute
        require_relative '../autodnsdb'

        opts = OptionParser.new do |optp|
          optp.banner = "Usage: vagrant autodns add <hostname> <ip> [vagrant_id]"
        end
        argv = parse_options(opts) || return
        #vagrant_id is an option parameter
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if (argv.length < 2 || argv.length > 3)

        hostname, ip, vagrant_id = argv

        if VagrantAutoDNS.autodnsdb.update_record(hostname, ip, vagrant_id)
          @env.ui.info("Entry #{ip} added for host #{hostname}")
          0
        else
          @env.ui.error("Entry #{ip} not added for host #{hostname}")
          1
        end
      end

    end
  end
end

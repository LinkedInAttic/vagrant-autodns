#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

module VagrantAutoDNS
  class Command
    class Status < Vagrant.plugin("2", :command)
      def execute
        require_relative '../daemon'

        opts = OptionParser.new do |optp|
          optp.banner = "Usage: vagrant autodns [re]start"
        end
        argv = parse_options(opts) || return
        #Takes no arguments
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if (argv.length != 0)

        @env.ui.success("Daemon status is #{VagrantAutoDNS::Daemon.daemon_status}")
        0
      end
    end
  end
end

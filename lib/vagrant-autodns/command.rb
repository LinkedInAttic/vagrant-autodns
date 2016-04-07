#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

module VagrantAutoDNS
  class Command < Vagrant.plugin('2', :command) 

    def self.synopsis
      'manages DNS for intra-guest communication'
    end

    #Available subcommands
    def initialize(*args)
      super(*args)

      @main_args, @sub_command, @sub_args = split_main_and_subcommand(@argv)

      @subcommands = Vagrant::Registry.new

      @subcommands.register(:stop) do
        require_relative 'commands/stop'
        Stop
      end

      @subcommands.register(:start) do
        require_relative 'commands/restart'
        Restart
      end

      @subcommands.register(:status) do
        require_relative 'commands/status'
        Status
      end

      @subcommands.register(:restart) do
        require_relative 'commands/restart'
        Restart
      end

      @subcommands.register(:add) do
        require_relative 'commands/add'
        Add
      end

      @subcommands.register(:delete) do
        require_relative 'commands/delete'
        Delete
      end

      @subcommands.register(:list) do
        require_relative 'commands/list'
        List
      end

      @subcommands.register(:clear) do
        require_relative 'commands/clear'
        Clear
      end

      @subcommands.register(:reload_all) do
        require_relative 'commands/reload_all'
        Reload
      end
    end

    #Main function called
    def execute
      if @main_args.include?('-h') || @main_args.include?('--help')
        # Print the help for all the autodns commands.
        return help
      end

      # If we reached this far then we must have a subcommand. If not,
      # then we also just print the help and exit.
      command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
      return help if !command_class || !@sub_command
      @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

      # Hack to ensure Vagrantfile gets loaded
      @env.vagrantfile

      # Initialize and execute the command class
      command_class.new(@sub_args, @env).execute
    end

    # Prints the help out for this command
    def help
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant autodns <command> [<args>]"
        opts.separator ""
        opts.separator "Available subcommands:"

        # Add the available subcommands as separators in order to print them
        # out as well.
        keys = []
        @subcommands.each { |key, value| keys << key.to_s }

        keys.sort.each do |key|
          opts.separator "     #{key}"
        end

        opts.separator ""
        opts.separator "For help on any individual command run `vagrant autodns COMMAND -h`"
      end

      @env.ui.info(opts.help, :prefix => false)
    end
  end
end

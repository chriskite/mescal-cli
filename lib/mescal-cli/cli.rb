require 'etc'
require 'thread'

module MescalCli
  class Cli
    def initialize(config)
      @config = config
      @client = Client.new(config['mescal'])
      @image = config['image']
      @cmd = config['cmd']
      @user = Etc.getlogin
    end

    def run!
      puts "Sending task to Mescal..."
      task = Task.create(@client, @image, @cmd, @user)
      run = true
      pailer_thread = nil
      while(run) do
        sleep(2)
        state = task.state
        task.update!
        if state != task.state
          puts "State: #{task.state}"
          if task.state != "TASK_PENDING" && pailer_thread.nil?
            pailer_thread = Thread.new { Pailer.new(task, @config['mescal']).run! }
          end
        end

        run = !task.done?
      end
      puts "Exiting..."
      sleep(1)
      pailer_thread.kill if !!pailer_thread
    end
  end
end

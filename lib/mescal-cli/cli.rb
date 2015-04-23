require 'etc'

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
      while(run) do
        sleep(2)
        state = task.state
        task.update!
        if state != task.state
          puts "State: #{task.state}"
        end

        run = !task.done?
      end
      puts "Exiting..."
    end
  end
end

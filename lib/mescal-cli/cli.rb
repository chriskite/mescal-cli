require 'etc'
require 'thread'

module MescalCli
  class Cli
    def initialize(config)
      @mode = ARGV.first
      usage and System.exit(1) unless !!@mode
      @config = config
      @client = Client.new(config['mescal'])
      @image = config['image']
      @cmd = ARGV[1] || config['cmd']
      @sshCmd = config['sshCmd']
    end

    def usage
      puts "mescal [run|ssh]"
    end

    def run!
      case @mode
      when "run" then run
      when "ssh" then ssh
      when "list" then list
      end
    end

    def list
      tp Task.list(@client), {id: {width: 48}}, :image, :cmd, :state
    end

    def run
      puts "Sending task to Mescal..."
      task = Task.create(@client, @image, @cmd)
      run = true
      threads = []
      pailer_started = false
      while(run) do
        sleep(2)
        state = task.state
        task.update!
        if state != task.state
          puts "State: #{task.state}"
          if task.state != "TASK_PENDING" && !pailer_started
            pailer_started = true
            ["stdout", "stderr"].each do |std|
              threads << Thread.new { Pailer.new(task, @config['mescal'], std).run! }
            end
          end
        end

        run = !task.done?
      end
      sleep(10)
      threads.each { |t| t.kill }
    end

    def ssh
      task = Task.create(@client, @image, @sshCmd)
      run = true
      while(run) do
        sleep(2)
        state = task.state
        task.update!
        if state != task.state
          if task.state != "TASK_PENDING"
            Ssh.new(task).run!
          end
        end

        run = !task.done?
      end
    end

  end
end

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
      @sshCmd = config['sshCmd']
      @cpus = config['cpus']
      @mem = config['mem']
    end

    def usage
      puts "mescal [run|ssh]"
    end

    def run!
      case @mode
      when "run" then run
      when "ssh" then ssh
      when "list" then list
      when "kill" then kill
      end
    end

    def list
      tp Task.list(@client), {id: {width: 48}}, :image, :cmd, :state
    end

    def run
      @cmd = ARGV[1] || @config['cmd']
      puts "Sending task to Mescal..."
      task = Task.create(@client, @image, @cmd, @cpus, @mem)
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
      @cmd = ARGV[1] || @config['cmd']
      task = Task.create(@client, @image, @sshCmd, @cpus, @mem)
      run = true
      while(run) do
        sleep(2)
        state = task.state
        task.update!
        if state != task.state
          if task.state == "TASK_RUNNING"
            Ssh.new(task).run!
          elsif task.state != "TASK_PENDING"
            puts "Task exited with state #{task.state} before ssh could connect"
          end
        end

        run = !task.done?
      end
    end

    def kill
      @id = ARGV[1]
      if(killed = Task.kill(@client, @id))
        puts "Killed #{killed}"
      else
        puts "Failed to kill #{@id}"
      end
    end

  end
end

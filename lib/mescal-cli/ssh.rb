module MescalCli
  class Ssh
    def initialize(task)
      @task = task
    end

    def run!
      ip = @task.slave_ip
      port = @task.ssh_port
      killer = "#{$0} kill #{@task.id}"
      puts "SSH'ing to root@#{ip}:#{port}"
      exec "ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@#{ip} -p #{port}; #{killer}"
    end
  end
end

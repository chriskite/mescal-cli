module MescalCli
  class Ssh
    def initialize(task)
      @task = task
    end

    def run!
      ip = @task.slave_ip
      port = @task.ssh_port
      exec "ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@#{ip} -p #{port}"
    end
  end
end

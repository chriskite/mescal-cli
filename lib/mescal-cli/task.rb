module MescalCli
  class Task
    attr_reader :id, :state, :slave_id

    def self.create(client, image, cmd, user)
      resp = client.task.create(image, cmd, user)
      obj = MultiJson.load(resp)
      Task.new(client, obj['id'], image, cmd, user)
    end

    def initialize(client, id, image, cmd, user)
      @client, @id, @image, @cmd, @user = client, id, image, cmd, user
    end

    def update!
      resp = @client.task.get(@id)
      obj = MultiJson.load(resp)
      @state = obj['state']
      @slave_id = obj['slaveId']
      @ports = obj['ports']
    end

    def done?
      ['TASK_FINISHED', 'TASK_LOST', 'TASK_FAILED'].include?(@state)
    end

    def slave_ip
      resp = @client.slave.get(@slave_id)
      obj = MultiJson.load(resp)
      obj['hostname']
    end

    def ssh_port
      @ports.find { |p| p[0] == 22 }[1]
    end
  end
end

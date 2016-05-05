module MescalCli
  class Task
    attr_reader :id, :image, :cmd, :slave_id, :started
    attr_accessor :state

    def self.create(client, image, cmd, cpus, mem)
      resp = client.task.create(image, cmd, cpus, mem)
      obj = MultiJson.load(resp)
      Task.new(client, obj['id'], image, cmd)
    end

    def self.list(client)
      resp = client.task.list
      obj = MultiJson.load(resp)
      obj.map do |jsTask|
        t = Task.new(nil, jsTask['id'], jsTask['image'], jsTask['cmd'], jsTask['createdAt'])
        t.state = jsTask['state']
        t
      end
    end

    def self.kill(client, id)
      resp = client.task.kill(id) rescue nil
      if(resp && obj = MultiJson.load(resp))
        obj['id']
      else
        nil
      end
    end

    def initialize(client, id, image, cmd, started = nil)
      @client, @id, @image, @cmd, @started = client, id, image, cmd, started
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

    def to_s
      "#{@id} #{@image} #{@cmd}"
    end
  end
end

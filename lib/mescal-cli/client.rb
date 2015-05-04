module MescalCli
  class Client
    def initialize(host)
      @base_url = "http://#{host}/"
    end

    def task
      TaskClient.new(@base_url)
    end
  end

  class TaskClient
    def initialize(base_url)
      @base_url = base_url + "tasks"
    end

    def create(image, cmd, user)
      RestClient.post @base_url, image: image, cmd: cmd, port: 22
    end

    def get(id)
      RestClient.get "#{@base_url}/#{id}"
    end
  end
end

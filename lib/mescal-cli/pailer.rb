require 'net/http'
require 'uri'

module MescalCli
  class Pailer
    def initialize(task, host)
      @task, @host = task, host
    end

    def run!
      uri = URI('http://' + @host + '/outputs/' + @task.id)
      STDOUT.flush
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request Net::HTTP::Get.new(uri) do |response|
          response.read_body do |chunk|
            print chunk
            STDOUT.flush
          end
        end
      end
    end
  end
end

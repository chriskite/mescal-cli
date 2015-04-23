require 'delegate'

module MescalCli
  class Config < Delegator
    def self.load(file)
      Config.new(MultiJson.load(open(file).read))
    end

    def initialize(obj)
      super
      @delegate_obj = obj
    end

    def __getobj__
      @delegate_obj
    end

    def __setobj__(obj)
      @delegate_obj = obj
    end
  end
end

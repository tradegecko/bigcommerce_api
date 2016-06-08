module BigcommerceAPI
  class BaseError < StandardError
    attr_reader :code
    def initialize(code, message)
      @code = code
      super(message)
    end
  end

  class Error < BaseError; end
  class ClientError < BaseError; end
end

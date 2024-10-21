class Request
  
  attr_reader :method, :resource

  def initialize(request_string)
    @method = :get
    @resource = "/"
  end
end
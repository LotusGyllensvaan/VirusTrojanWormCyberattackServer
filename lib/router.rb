require 'erb'

class Router
  def initialize
    @routes = []
  end

  def add_route(method, resource, block)
    #Parameters are declared in resource string:  "/:[parameter]"
    #ToDo: Read resource -> Find beginning slash -> Read between / and /
    #-> return to hash of params.






    @routes << {method: method, resource: resource, block: block}
  end

  def get(resource, &block)
    add_route(:get, resource, block)
  end

  def post(resource, &block)
    add_route(:post, resource, block)
  end

  def match_route(request)
    #ToDo: Add parameters to matching
    puts "matching route..."
    match = @routes.find { |route| route[:method] == request.method && route[:resource] == request.resource }
    puts match ? "match found at #{match[:method].to_s.upcase} #{match[:resource]}" : "match not found"

    if match
      status = 200

      func = match[:block]
      func_params = func.parameters
      req_params = request.params

      func_params_to_s = func_params.map { |arrs| arrs.last.to_s }

      html = func.call(*req_params.values_at(*func_params_to_s))
    else
      status = 404
      html = "<h1>404: Page Not Found</h1>"
    end

    [status, html]
  end

end
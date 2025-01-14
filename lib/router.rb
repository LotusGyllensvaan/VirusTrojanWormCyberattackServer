require 'erb'

class Router
  def initialize
    @routes = []
  end

  def add_route(method, resource, &block)
    @routes << {method: method, resource: resource, block: block}
  end

  def match_route(request)
    puts "matching route..."
    match = @routes.find { |route| route[:method] == request.method && route[:resource] == request.resource }
    puts match ? "match found at #{match[:method].to_s.upcase} #{match[:resource]}" : "match not found"

    if match
      status = 200
      p html = match[:block].call
    else
      status = 404
      html = "<h1>404: Page Not Found</h1>"
    end

    [status, html]
  end

end
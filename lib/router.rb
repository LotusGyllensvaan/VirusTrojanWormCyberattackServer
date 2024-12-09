class Router
  def initialize
    @routes = []
  end

  def add_route(method, resource)
    #html = yield
    @routes << [method, resource]
    p @routes
  end

  def match_route(request)
    puts "matching route..."
    match = @routes.include? [request.method, request.resource]
    puts match ? "match found" : "match not found"
    #status = match ? 200 : 404
    #html = 
  end

end

require 'erb'

class Router
  def initialize
    @routes = []
    add_public_routes()
  end

  def add_public_routes()
      public_files = Dir["public/*"].map { |file| File.new(file) }
      public_files.each { |file| @routes << {method: :get, resource: "/#{File.basename(file)}", content: File.read(file)} }
  end

  def add_route(method, resource, block)
    resource.gsub!(/:\w+/, "(\\w+)")
    resource = Regexp.new(resource)

    @routes << {method: method, resource: resource, block: block}
  end

  def get(resource, &block)
    add_route(:get, resource, block)
  end

  def post(resource, &block)
    add_route(:post, resource, block)
  end

  def match_route(request)
    puts "matching route..."
    match = @routes.find { |route| route[:method] == request.method && route[:resource].match?(request.resource) }
    puts match ? "match found at #{match[:method].to_s.upcase} #{match[:resource]}" : "match not found"

    if match
      status = 200
      content = match[:content]
      if match[:block]
        match_data = match[:resource].match(request.resource)

        content = match[:block].call(*match_data.captures)
      end
    else
      status = 404
      content = "<h1>404: Page Not Found</h1>"
    end

    [status, content]
  end

end
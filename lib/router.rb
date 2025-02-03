require 'erb'

class Router
  def initialize
    @routes = []
    add_public_routes()
  end

  def add_public_routes()
      public_resources = Dir["public/*"].map { |file| "/#{File.basename(file)}" }
      public_resources.each { |file| @routes << {method: :get, resource: file} }
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
      html = ""
      if match[:block]
        match_data = match[:resource].match(request.resource)

        html = match[:block].call(*match_data.captures)
      end
    else
      status = 404
      html = "<h1>404: Page Not Found</h1>"
    end

    [status, html]
  end

end
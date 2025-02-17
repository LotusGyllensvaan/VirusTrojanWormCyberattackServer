class Router
  def initialize
    @routes = []
    add_public_routes()
  end

  def add_public_routes()
      public_files = Dir["public/**/*"].filter_map { |path| File.new(path) if File.file?(path) }
      public_files.each { |file| @routes << {method: :get, resource: "/#{file.to_path}", content: File.binread(file)} }
      @routes.each { |ro| p ro[:resource] if ro[:content] }
  end

  def add_route(method, resource, block)
    resource.gsub!(/:\w+/, "(\\w+)")
    puts "Regex Resources ----------------"
    p resource = Regexp.new(resource)
    puts "--------------------------------"
    @routes << {method: method, resource: resource, block: block}
  end

  def get(resource, &block)
    add_route(:get, resource, block)
  end

  def post(resource, &block)
    add_route(:post, resource, block)
  end

  def match_route(request)
    puts "\n"
    puts "matching #{request.resource}..."
    match = @routes.find { |route| route[:method] == request.method && route[:resource].match?(request.resource) }
    puts match ? "matched with #{match[:method].to_s.upcase} #{match[:resource]}" : "match not found"
  
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
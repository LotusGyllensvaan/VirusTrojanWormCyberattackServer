# frozen_string_literal: true
require 'cgi'

class Router
  def initialize
    @routes = []
    add_public_routes
  end

  def add_public_routes
    Dir.glob('public/**/*').each do |path|
      next unless File.file?(path)
      @routes << { method: :get, resource: "/#{path.sub('public/', '')}"}
    end
  end

  def add_route(method, resource, block)
    resource = Regexp.new(resource.gsub(/:\w+/, '(\\w+)'))
    @routes << { method: method, resource: resource, block: block }
  end

  def get(resource, &block)
    add_route(:get, resource, block)
  end

  def post(resource, &block)
    add_route(:post, resource, block)
  end

  def match_route(request)
    
    puts "\nmatching #{request.resource}..."
    route = find_route(request)

    route ? process_route(route, request) : not_found_response
  end

  private

  def find_route(request)
    request_resource = CGI.unescape(request.resource)
    
    @routes.find do |route|
      route_resource = route[:resource].is_a?(String) ? Regexp.new(Regexp.escape(route[:resource])) : route[:resource] 
      route[:method] == request.method &&
        request_resource.match?(route_resource)
    end

  end

  def process_route(route, request)
    log_match(route)
    if dynamic_route?(route)
      execute_dynamic_route(route, request)
    else
      serve_static_asset(route)
    end
  end

  def dynamic_route?(route)
    route[:block].respond_to?(:call)
  end

  def execute_dynamic_route(route, request)
    match_data = route[:resource].match(request.resource)
    content = route[:block].call(*match_data.captures)
    success_response(content)
  end

  def serve_static_asset(route)
    content = File.binread("public#{route[:resource]}")
    success_response(content)
  end

  def success_response(content)
    [200, content]
  end

  def not_found_response(message = 'Page not found')
    log_error(message)
    [404, "<h1>404: #{ERB::Util.html_escape(message)}</h1>"]
  end

  #Helper saker: Ta bort innan inlämning

  def log_error(message)
    puts "ERROR: #{message}"
  end

  def log_match(route)
    puts "Matched #{route[:method].to_s.upcase} #{route[:resource]}"
  end
end
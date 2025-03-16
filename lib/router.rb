# frozen_string_literal: true
require 'cgi'
require_relative 'mimes'

class Router
  attr_accessor :routes
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

  def route(method, resource, block)
    resource = Regexp.new(resource.gsub(/:\w+/, '(\\w+)'))
    @routes << { method: method, resource: resource, block: block }
  end

  def get(resource, &block)
    route(:get, resource, block)
  end

  def post(resource, &block)
    route(:post, resource, block)
  end

  def match_route(request)
    #puts "\nmatching #{request.method} #{request.resource}..."
    route = find_route(request)

    route ? process_route(route, request) : not_found_response(request.resource)
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
    #log_match(route)
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
    result = route[:block].call(*match_data.captures)
    if result.is_a?(Response)
      [result.status, result.body, result.headers]
    else
      content_type = 'text/html'
      headers = content_type_header(content_type)
      [200, result, headers]
    end
  end

  def serve_static_asset(route)
    asset_path = "public#{route[:resource]}"
    content = File.binread(asset_path)
    content_type = Mime.to_mime(File.extname(asset_path))
    headers = {}
    headers['Content-Type: '] = content_type
    headers['Cache-Control: '] = 'max-age=31536000'

    [200, content, headers]
  end

  def content_type_header(content_type)
    { 'Content-Type: ' => content_type }
  end

  def success_response(content, content_type)
    [200, content, content_type]
  end

  def not_found_response(resource, message = 'Page not found')
    log_error(message)
    content_type = (mime_type = Mime.to_mime(File.extname(resource))) ? mime_type : ''
    
    [404, "<h1>404: #{message}</h1>", content_type_header(content_type)]
  end

  #Helper saker: Ta bort innan inlämning

  def log_error(message)
    puts "ERROR: #{message}"
  end

  def log_match(route)
    puts "Matched #{route[:method].to_s.upcase} #{route[:resource]}"
  end
end
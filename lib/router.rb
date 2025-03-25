# frozen_string_literal: true
require 'cgi'
require_relative 'mimes'

##
# The Router class manages request routing by defining and matching routes.
# It supports static file serving and dynamic route handling.
class Router
  # @return [Array<Hash>] List of defined routes.
  attr_accessor :routes

  ##
  # Initializes the Router instance and loads public routes.
  def initialize
    @routes = []
    add_public_routes
  end

  ##
  # Adds all public files as GET routes.
  def add_public_routes
    Dir.glob('public/**/*').each do |path|
      next unless File.file?(path)
      @routes << { method: :get, resource: "/#{path.sub('public/', '')}" }
    end
  end

  ##
  # Defines a new route.
  # @param method [Symbol] The HTTP method (:get, :post, etc.).
  # @param resource [String] The route pattern.
  # @param block [Proc] The block to execute for dynamic routes.
  def route(method, resource, block)
    resource = Regexp.new(resource.gsub(/:\w+/, '(\\w+)'))
    @routes << { method: method, resource: resource, block: block }
  end

  ##
  # Matches an incoming request to a defined route.
  # @param request [Object] The request object with method and resource attributes.
  # @return [Array] The response array containing status, body, and headers.
  def match_route(request)
    puts "\nmatching #{request.method} #{request.resource}..."
    route = find_route(request)

    route ? process_route(route, request) : not_found_response(request.resource)
  end

  private

  ##
  # Finds a matching route for the given request.
  # @param request [Object] The request object.
  # @return [Hash, nil] The matching route or nil if no match is found.
  def find_route(request)
    request_resource = CGI.unescape(request.resource)
    
    @routes.find do |route|
      route_resource = route[:resource].is_a?(String) ? Regexp.new(Regexp.escape(route[:resource])) : route[:resource]
      route[:method] == request.method && request_resource.match?(route_resource)
    end
  end

  ##
  # Processes a matched route.
  # @param route [Hash] The matched route.
  # @param request [Object] The request object.
  # @return [Array] The response array.
  def process_route(route, request)
    log_match(route)
    if dynamic_route?(route)
      execute_dynamic_route(route, request)
    else
      serve_static_asset(route)
    end
  end

  ##
  # Checks if a route is dynamic (i.e., has an associated block).
  # @param route [Hash] The route to check.
  # @return [Boolean] True if the route is dynamic, false otherwise.
  def dynamic_route?(route)
    route[:block].respond_to?(:call)
  end

  ##
  # Executes a dynamic route block.
  # @param route [Hash] The route with a block.
  # @param request [Object] The request object.
  # @return [Array] The response array.
  def execute_dynamic_route(route, request)
    match_data = route[:resource].match(request.resource)
    result = route[:block].call(*match_data.captures)
    if result.is_a?(Response)
      [result.status, result.body, result.headers]
    else
      headers = {}
      [200, result, headers]
    end
  end

  ##
  # Serves a static asset from the public folder.
  # @param route [Hash] The matched static route.
  # @return [Array] The response array.
  def serve_static_asset(route)
    asset_path = "public#{route[:resource]}"
    content = File.binread(asset_path)
    headers = {}

    [200, content, headers]
  end

  ##
  # Generates a Content-Type header.
  # @param content_type [String] The MIME type.
  # @return [Hash] The Content-Type header.
  def content_type_header(content_type)
    { 'Content-Type: ' => content_type }
  end

  ##
  # Creates a success response.
  # @param content [String] The response body.
  # @param content_type [String] The content type.
  # @return [Array] The response array.
  def success_response(content, content_type)
    [200, content, content_type]
  end

  ##
  # Creates a 404 Not Found response.
  # @param resource [String] The requested resource.
  # @param message [String] The error message.
  # @return [Array] The response array.
  def not_found_response(resource, message = 'Page not found')
    log_error(message)
    content_type = (mime_type = Mime.to_mime(File.extname(resource))) ? mime_type : ''
    
    [404, "<h1>404: #{message}</h1>", content_type_header(content_type)]
  end

  ##
  # Logs an error message.
  # @param message [String] The error message.
  def log_error(message)
    puts "ERROR: #{message}"
  end

  ##
  # Logs a matched route.
  # @param route [Hash] The matched route.
  def log_match(route)
    puts "Matched #{route[:method].to_s.upcase} #{route[:resource]}"
  end
end

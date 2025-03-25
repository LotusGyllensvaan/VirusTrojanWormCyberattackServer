# frozen_string_literal: true

require 'cgi'

# Process an HTTP request
class Request
  # @return [Symbol] The HTTP method (e.g., :get, :post)
  # @return [String] The requested resource path
  # @return [String] The HTTP version used in the request
  # @return [Hash{String => String}] A hash of HTTP headers
  # @return [Hash{String => String}] A hash of request parameters, combining both query string and body parameters
  attr_reader :method, :resource, :version, :headers, :params

  # Regular expression pattern for parsing header parameters.
  HEADER_PARAM = /\s*[\w.]+=(?:[\w.]+|"(?:[^"\\]|\\.)*")?\s*/.freeze

  # Initializes a new Request object by parsing the raw HTTP request string.
  #
  # @param request_string [String] The raw HTTP request as a string.
  def initialize(request_string)
    lines = request_string.lines(chomp: true)
    request = parse_request(lines.first)

    @method, @resource, @version = request
    @headers = parse_headers(lines)

    query_params = parse_query_params(@resource)
    body_params = parse_body_params(lines)

    @params = query_params.merge(body_params)
  end

  # Parses the request line to extract the HTTP method, resource, and version.
  #
  # @param request_line [String] The first line of the HTTP request.
  # @return [Array<(Symbol, String, String)>] An array containing the HTTP method as a symbol, the resource as a string, and the HTTP version as a string.
  def parse_request(request_line)
    request = request_line.split(' ', 3)
    request[0] = request[0].downcase.to_sym
    request
  end

  # Parses the header lines to extract HTTP headers into a hash.
  #
  # @param lines [Array<String>] The lines of the HTTP request.
  # @return [Hash{String => String}] A hash where the keys are header names and the values are header values.
  def parse_headers(lines)
    lines.filter_map do |line|
      pair = line.split(': ', 2)
      pair if pair.length == 2
    end.to_h
  end

  # Parses the resource string to extract query parameters.
  #
  # @param resource [String] The resource string from the request line.
  # @return [Hash{String => String}] A hash of query parameters.
  def parse_query_params(resource)
    return {} unless resource.include?('?')

    params = resource.split('?', 2).last
    pairs = params.split('&')
    pairs.map { |pair| pair.split('=', 2) }.to_h
  end

  # Parses the body lines to extract parameters from form data.
  #
  # @param lines [Array<String>] The lines of the HTTP request.
  # @return [Hash{String => String}] A hash of body parameters.
  def parse_body_params(lines)
    params = lines.drop(1).find_all { |line| line.include?('=') }
    return {} unless params

    params_to_h(params)
  end

  # Parses header-style parameters from a request string.
  #
  # @param request [String] The request string containing parameters.
  # @return [Hash{String => String}] A hash of parsed parameters.
  def parse_params(request)
    params = request.scan(HEADER_PARAM).map! do |s|
      key, value = s.strip.split('=', 2)
      value = value[1..-2].gsub(/\\(.)/, '\\1') if value.start_with?('"')
      [key.downcase, value]
    end
    params.to_h
  end

  # Converts an array of parameter strings into a hash.
  #
  # @param params [Array<String>] An array of parameter strings.
  # @return [Hash{String => String}] A hash of parameters.
  def params_to_h(params)
    pairable = params.filter { |p| p.include? '&' || p.match(/\;|\:/) }
    pairs = []
    pairs = pairable.map { |p| p.split('&') if p.include? '&' }.first if pairable.length > 0
    mapped_pairs = pairs.map { |pair| pair.split('=', 2) }.to_h

    unless mapped_pairs.empty?
      mapped_pairs.transform_values { |v| CGI.unescape(v) }
    else
      mapped_pairs
    end
  end

  # Extracts the media type from a Content-Type header.
  #
  # @param content_type [String, nil] The Content-Type header value.
  # @return [String, nil] The media type, or nil if the content type is not provided.
  def type(content_type)
    return nil unless content_type && !content_type.empty?
    split_pattern = /[;,]/
    type = content_type.split(split_pattern, 2).first
    type.rstrip!
    type.downcase!
    type
  end

  # Retrieves the Content-Type header from the request headers.
  #
  # @return [String, nil] The Content-Type header value, or nil if not present.
  def content_type
    content_type = self.headers['Content-Type']
    content_type.nil? || content_type.empty? ? nil : content_type
  end

  # Determines the media type of the request.
  #
  # @return [String, nil] The media type, or nil if not determinable.
  def media_type
    type(content_type)
  end

  # Media types that are considered form data.
  FORM_DATA_MEDIA_TYPES = [
    'application/x-www-form-urlencoded',
    'multipart/form-data'
  ]

  # Determines if the request contains form data.
  #
  # @return [Boolean] True if the request method is POST and the media type is form data or nil; otherwise, false.
  def form_data?
    type = media_type
    method = self.method

    (method == :post && type.nil?) || FORM_DATA_MEDIA_TYPES.include?(type)
  end
end

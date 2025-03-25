require 'time'

##
# The Response class represents an HTTP response with status, headers, and body.
class Response
  # @return [Integer] The HTTP status code.
  attr_accessor :status, :body
  # @return [Hash] The HTTP headers.
  attr_reader :headers

  ##
  # Initializes a Response object.
  # @param session [Object, nil] The session object for sending the response.
  # @param status [Integer] The HTTP status code (default: 200).
  # @param body [String, nil] The response body.
  # @param headers [Hash] The HTTP headers.
  def initialize(session = nil, status = 200, body = nil, headers = {})
    @session = session
    @status = status.to_i
    @headers = headers
    @body = body
  end

  ##
  # Creates a new Response instance.
  # @param session [Object] The session object.
  # @param status [Integer] The HTTP status code.
  # @param headers [Hash] The HTTP headers.
  # @param body [String] The response body.
  # @return [Response] A new Response instance.
  def self.[](session, status, headers, body)
    Response.new(session, status, body, headers)
  end

  ##
  # Sets response properties.
  # @param session [Object] The session object.
  # @param status [Integer] The HTTP status code.
  # @param headers [Hash] The HTTP headers.
  # @param body [String] The response body.
  def set(session, status, headers, body)
    @session = session
    @status = status unless status.between?(300, 399)
    @body = body
    set_default_headers
    @headers = @headers.merge(headers)
  end

  ##
  # Sets default headers for the response.
  def set_default_headers
    get_content_length
    set_header 'connection', 'keep-alive'
    set_header 'date', Time.now.httpdate
    set_header 'server', 'VirusTrojanWormCyberattackServer-v1'
    set_header 'x-content-type-options:', 'nosniff'
    set_header 'x-frame-options:', 'SAMEORIGIN'
    set_header 'x-xss-protection:', '1; mode=block'
  end

  ##
  # Sets a specific header.
  # @param key [String] The header name.
  # @param value [String] The header value.
  def set_header(key, value)
    @headers["#{key.downcase}: "] = value.to_s
  end

  ##
  # Sets the Content-Type header.
  # @param content_type [String] The MIME type of the response.
  def content_type=(content_type)
    set_header 'Content-Type', content_type
  end

  ##
  # Sets the Content-Length header.
  # @param content_length [Integer] The length of the response body.
  def content_length=(content_length)
    set_header 'content-length', content_length
  end

  ##
  # Ensures the Content-Length header is set.
  def get_content_length
    set_header 'content-length', @body.bytesize unless @headers['content-length']
  end

  ##
  # Sets the Location header.
  # @param location [String] The URL to redirect to.
  def location=(location)
    set_header 'Location: ', location
  end

  ##
  # Redirects to a target URL.
  # @param target [String] The redirection target.
  # @param status [Integer] The redirection status code (default: 302).
  # @return [Response] The updated response instance.
  def redirect(target, status = 302)
    self.status = status
    self.location = target
    self.body = ''
    self
  end

  ##
  # Sends the response over the session.
  def respond
    @session.print "HTTP/1.1 #{@status}\r\n"
    @headers.each { |k, v| @session.print(k + v + "\r\n") }
    @session.print "\r\n"
    @session.print @body
    @session.close
  end
end
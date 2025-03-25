# frozen_string_literal: true

require 'socket'
require_relative 'request'
require_relative 'router'
require_relative 'response'
require_relative 'mimes'

# A simple HTTP server implementation that handles GET and POST requests.
class HTTPServer
  # Initializes a new instance of the HTTPServer.
  #
  # @param port [Integer] the port number on which the server will listen. Default is 4567.
  def initialize(port = 4567)
    @port = port
    @router ||= Router.new
    @params = {}
  end

  # Starts the server and listens for incoming connections.
  # For each connection, a new thread is spawned to handle the request.
  def start
    puts "Listening on #{@port}"

    Socket.tcp_server_loop(@port) do |sock, _client_addrinfo|
      Thread.new do
        data = read_stream sock
        @request = Request.new(data)

        finish(@request, sock)
      ensure
        sock.close
      end
    end
  end

  # Reads data from the socket stream.
  #
  # @param socket [Socket] the socket from which to read the data.
  # @return [String] the complete data read from the socket, including headers and body.
  def read_stream(socket)
    data = ''
    while (line = socket.gets) && line !~ (/^\s*$/)
      data += line
    end

    content_length = data[/^Content-Length: (\d+)/i, 1].to_i

    if content_length.positive?
      data += "\r\n"
      data += socket.read(content_length)
    end
    data
  end

  # Finishes processing the request by generating a response and sending it back to the client.
  #
  # @param request [Request] the request object containing the client's request data.
  # @param session [Socket] the socket session used to send the response back to the client.
  def finish(request, session)
    @response = Response.new
    status, body, headers = @router.match_route(request)

    @response.content_type = if request.form_data?
                               request.media_type
                             else
                               Mime.to_mime(File.extname(request.resource))
                             end

    @response.set(session, status, headers, body)
    @response.respond
  end

  # Defines a GET route for the server.
  #
  # @param resource [String] the resource path for the route.
  # @param block [Proc] the block to execute when the route is matched.
  def get(resource, &block)
    @router.route(:get, resource, block)
  end

  # Defines a POST route for the server.
  #
  # @param resource [String] the resource path for the route.
  # @param block [Proc] the block to execute when the route is matched.
  def post(resource, &block)
    @router.route(:post, resource, block)
  end

  # Redirects the client to a different URL.
  #
  # @param target [String] the URL to redirect to.
  # @param status [Integer] the HTTP status code for the redirect. Default is 302.
  def redirect(target, status = 302)
    @response.redirect target, status
  end

  # Retrieves the parameters from the request.
  #
  # @return [Hash] the parameters parsed from the request.
  def params
    @request.params
  end
end
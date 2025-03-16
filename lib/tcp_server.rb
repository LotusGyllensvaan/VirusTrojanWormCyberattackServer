# frozen_string_literal: true

require 'socket'
require_relative 'request'
require_relative 'router'
require_relative 'response'

class HTTPServer

  def initialize(router, port = 4567)
    @port = port
    @router = router
    @params = {}
  end

  def start()
    puts "Listening on #{@port}"

    Socket.tcp_server_loop(@port) {|sock, client_addrinfo|
      Thread.new {
          begin
             data = read_stream sock
             @request = Request.new(data)
             #puts "-Data-"+"-"*40
             #puts data
             #puts "-Params-"+"-"*40
             @request.params
             finish(@request, sock)
          ensure
            sock.close
          end
        }
    }
  end

  def read_stream(socket)
    data = ''
    while ((line = socket.gets)) && line !~ (/^\s*$/)
      data += line
    end

    content_length = data[/^Content-Length: (\d+)/i, 1].to_i

    if content_length > 0
      data += "\r\n"
      data += socket.read(content_length)
    end
    data
  end

  def finish(request, session)
    status, body, headers = @router.match_route(request)
    @response = Response[session, status, headers, body]
    @response.respond
  end

  def params()
    @request.params
  end
end




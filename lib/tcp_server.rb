# frozen_string_literal: true

require 'socket'
require_relative 'request'
require_relative 'router'
require_relative 'response'

class HTTPServer

  def initialize(router, port=4567)
    @port = port
    @router = router
    @response
    @request
  end

  def start()
    server = TCPServer.new(@port)

    while (session = server.accept)
      data = listen_to session

      @request = Request.new(data)

      finish(@request, session)
    end
  end

  def listen_to(session)
    data = ''
    while ((line = session.gets)) && line !~ (/^\s*$/)
      data += line
    end
    data
  end

  def finish(request, session)
    @response = Response.new(session)
    status, content, content_type = @router.match_route(request)
    @response[session, status, {}, content]

    @response.content_type = content_type
    @response.respond
  end

  def self.run(router, port=4567)
    puts "Listening on #{port}"
    http_server = HTTPServer.new router
    http_server.start()
  end

  def self.redirect(location, status=302)
    @response.redirect(location, status)
  end
end




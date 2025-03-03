# frozen_string_literal: true

require 'socket'
require 'erb'
require 'sqlite3'
require_relative 'request'
require_relative 'router'
require_relative 'response'
require_relative 'render'

class HTTPServer
  def initialize(port)
    @port = port
  end

  def db
    return @db if @db
    @db = SQLite3::Database.new("../DB/database.sqlite")
    @db.results_as_hash = true
    
    return @db
  end

  def app(router, render)
    router.get '/index/:id/:a/:b' do |id, a, b|
      @id = id
      @a = a.to_i
      @b = b.to_i
      @product = db.execute('SELECT * FROM equipment WHERE id = ?', id).first
      render.erb('\test.erb', binding)
    end

    #router.get '/hello' do
    #  render.erb("\hello.erb", binding)
    #end

  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"
    router = Router.new
    render = Render.new

    app(router, render)

    while (session = server.accept)
      data = ''
      while ((line = session.gets)) && line !~ (/^\s*$/)
        data += line
      end
      # puts "RECEIVED REQUEST"
      # puts "-" * 40
      # puts data
      # puts "-" * 40

      request = Request.new(data)

      status, content = router.match_route(request)
      content_type = request.headers['Accept'] ? request.headers['Accept'].split(',').first : ''
      response = Response.new(session, status, content, content_type)
      response.respond
    end
  end
end


server = HTTPServer.new(4567)
server.start

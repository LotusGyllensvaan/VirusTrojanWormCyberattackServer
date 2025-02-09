require 'socket'
require_relative 'request'
require_relative 'router'
require_relative 'response'

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new

        router.get '/index/:id/:method' do |id, urf|
            #puts "---------"
            @id=id
            @urf=urf
            #puts "---------"
            erb("\index.erb")
        end

        router.get '/hello' do
            erb("\hello.erb")
        end

        def erb(template)
            template_path = File.join("views", "#{template}")
            raise "Template not found: #{template_path}" unless File.exist?(template_path)
            erb_content = File.read(template_path)
            ERB.new(erb_content).result(binding)
        end

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end
            #puts "RECEIVED REQUEST"
            #puts "-" * 40
            #puts data
            #puts "-" * 40 

            request = Request.new(data)

            status, content = router.match_route(request)
            content_type = request.headers["Accept"].split(",").first
            if content_type == "image/avif"
              content_type = "image/apng"
            end
            response = Response.new(session, status, content, content_type)
            response.respond
        end

    end

end


server = HTTPServer.new(4567)
server.start
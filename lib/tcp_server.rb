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
        
        router.add_route(:get, "/hello") do
            poopie = 10
            @poop = 5 + poopie
            puts "YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAh"
            erb("\index.erb")
        end

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end
            puts "RECEIVED REQUEST"
            puts "-" * 40
            puts data
            puts "-" * 40 

            request = Request.new(data)

            status, html = router.match_route(request)

            response = Response.new(session, status, html)
            response.respond
        end
    end

      #render erb template
    def erb(template)
        #search in default views folder
        template_path = File.join("views", "#{template}")
        raise "Template not found: #{template_path}" unless File.exist?(template_path)
        erb_content = File.read(template_path)
        ERB.new(erb_content).result(binding)
    end

end


server = HTTPServer.new(4567)
server.start
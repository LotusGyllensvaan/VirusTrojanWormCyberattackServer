class Response
  def initialize(session, status, html)
    @session = session
    @status = status
    @html = html
  end

  def respond
    @session.print "HTTP/1.1 #{@status}\r\n"
    @session.print "Content-Type: text/html\r\n"
    @session.print "\r\n"
    @session.print @html
    @session.close
  end
end

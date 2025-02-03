class Response
  def initialize(session, status, html, content_type)
    @session = session
    @status = status
    @html = html
    @content_type = content_type
  end

  def respond
    @session.print "HTTP/1.1 #{@status}\r\n"
    @session.print "Content-Type: #{@content_type}\r\n"
    @session.print "\r\n"
    @session.print @html
    @session.close
  end

end

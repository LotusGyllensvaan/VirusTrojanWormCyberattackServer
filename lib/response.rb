class Response

  attr_accessor :status, :body
  attr_reader :headers
  def initialize(session, status = 200, body = nil, headers = {})
    @session = session
    @status = status.to_i
    @headers = headers
    @body = body
  end

  def [](status, headers, body)
    @status = status
    @body = body
    @headers = headers
  end

  def set_header(key, value)
    @headers[key] = value
  end

  def content_type=(content_type)
    set_header 'Content-Type: ', content_type
  end

  def location=(location)
    set_header 'Location: ', location
  end

  def redirect(target, status = 302)
    @status = status
    location = target
  end

  def respond
    p @headers
    @session.print "HTTP/1.1 #{@status}\r\n"
    @headers.each { |k, v| @session.print(k+v+"\r\n") }
    @session.print "\r\n"
    @session.print @body
    @session.close
  end



end

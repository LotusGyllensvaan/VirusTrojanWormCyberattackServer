class Response

  attr_accessor :status, :body
  attr_reader :headers
  def initialize(session = nil, status = 200, body = nil, headers = {})
    @session = session
    @status = status.to_i
    @headers = headers
    @body = body
  end

  def self.[](session, status, headers, body)
    Response.new(session, status, body, headers)
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
    self.status = status
    self.location = target
    self.body = ''
    self
  end


  def respond
    @session.print "HTTP/1.1 #{@status}\r\n"
    @headers.each { |k, v| @session.print(k+v+"\r\n") }
    @session.print "\r\n"
    @session.print @body
    @session.close
  end



end

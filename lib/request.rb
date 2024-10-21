class Request
  
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    @request_lines = request_string.split("\n")

    @attributes = @request_lines.map { |line| line.split(": ")}
    @header_line = @attributes[0][0].split(" ")

    @method = @header_line[0].downcase.to_sym
    @resource = @header_line[1]
    @version = @header_line[2]

    @headers = @attributes.map { |key, value| [key, value] if key && value }.compact.to_h
  end
end
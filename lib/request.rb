class Request
  
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    @request_string_lines = request_string.split("\n")

    @header_elements = @request_string_lines.map { |line| line.split(": ")}
  
    @request_line = @header_elements[0][0].split(" ")

    @method = @request_line[0].downcase.to_sym
    @resource = @request_line[1]
    @version = @request_line[2]

    @headers = @header_elements.map { |key, value| [key, value] if key && value }.compact.to_h

    #query params
    
    @query_params_elements = @resource.partition("?").last.split("&")
    @query_params = Hash[@query_params_elements.map { |param| param.split("=") }]

    #body params
    @body_params_line = @request_string_lines.select { |line| line.include?("=")}[0]
    @body_params = @body_params_line.split("&").map { |pair| pair.split("=") }.to_h
    p @body_params
  end
end

request_string = File.read("get-fruits-with-filter.request.txt")
request = Request.new(request_string)
#p request.params

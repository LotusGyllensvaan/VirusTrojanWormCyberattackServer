# frozen_string_literal: true

# Process an HTTP request
class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    @request_string_lines = request_string.split("\n")
    @request_line = parse_request_line(@request_string_lines[0])
    
    @method = @request_line[0].downcase.to_sym
    @resource = @request_line[1]
    @version = @request_line[2]
    @headers = parse_headers(@request_string_lines)

    params_in_query = @resource.include?('?')

    if params_in_query
      @query_params_elements = @resource.partition('?').last.split('&')
      @params = Hash[@query_params_elements.map { |param| param.split('=') }]
    else
      @body_params_line = @request_string_lines.select { |line| line.include?('=') }[0]
      params_in_body = !@body_params_line.nil?
      @params = params_in_body ? @body_params_line.split('&').map { |pair| pair.split('=') }.to_h : {}
    end

  end

    def parse_request_line(request_line_string)
      request_line_parsed = request_line_string.split(' ')
    end

    def parse_headers(request_string_lines)
      request_string_lines.map.with_index {
         |line, index| line.split(": ") unless index == 0 
      }.compact.to_h
    end

    def parse_query_params(request_line)
      
    end
end

request_string = File.read('get-fruits-with-filter.request.txt')
request = Request.new(request_string)

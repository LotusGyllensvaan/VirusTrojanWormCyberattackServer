# frozen_string_literal: true

# Process an HTTP request
class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    @request_string_lines = request_string.split('\n')

    @header_elements = @request_string_lines.map { |line| line.split(': ') }

    @request_line = @header_elements[0][0].split(' ')

    @method = @request_line[0].downcase.to_sym
    @resource = @request_line[1]
    @version = @request_line[2]
    
    @headers = @header_elements.map { |key, value| [key, value] if key && value }.compact.to_h

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
end

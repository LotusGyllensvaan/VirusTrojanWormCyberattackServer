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

    query_params = parse_query_params(@resource)
    body_params = parse_body_params(@request_string_lines)

    @params = query_params.merge(body_params)
  end

    def parse_request_line(request_line_string)
      request_line_parsed = request_line_string.split(' ')
    end

    def parse_headers(request_string_lines)
      request_string_lines.map.with_index {
        |line, i| line.split(": ") unless line.split(": ").length <= 1 #Ändra detta så att man inte kör split 2 ggr
      }.compact.to_h
    end

    def parse_query_params(resource)
      if resource.include?("?")
        param_string = resource.split("?").last
        params_to_h(param_string)
      else
        {}
      end
    end

    def parse_body_params(request_string_lines)
      param_line = request_string_lines.find.with_index { |line, i| line.include?("=") unless i == 0}
      if !param_line.nil?
        params_to_h(param_line)
      else
        {}
      end
    end

    def params_to_h(param_string)
      delimiters = ['&', '=']
      param_string.split(Regexp.union(delimiters)).each_slice(2).to_h
    end
end


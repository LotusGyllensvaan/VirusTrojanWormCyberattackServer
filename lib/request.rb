# frozen_string_literal: true

# Process an HTTP request
class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    lines = request_string.lines(chomp: true)
    request = parse_request(lines.first)

    @method, @resource, @version = request
    @headers = parse_headers(lines)

    query_params = parse_query_params(@resource)
    body_params = parse_body_params(lines)

    @params = query_params.merge(body_params)
  end

  def parse_request(request_line)
    request = request_line.split(' ', 3)
    request[0] = request[0].downcase.to_sym
    request
  end

  def parse_headers(lines)
    lines.filter_map do |line|
      pair = line.split(': ', 2)
      pair if pair.length == 2
    end.to_h
  end

  def parse_query_params(resource)
    return {} unless resource.include?('?')

    params = resource.split('?', 2).last
    params_to_h(params)
  end

  def parse_body_params(lines)
    params = lines.drop(1).find { |line| line.include?('=') }
    return {} unless params

    params_to_h(params)
  end

  def params_to_h(params)
    pairs = params.split('&')
    pairs.map { |pair| pair.split('=', 2) }.to_h
  end
end

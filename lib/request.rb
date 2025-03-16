# frozen_string_literal: true

require 'cgi'

# Process an HTTP request
class Request
  attr_reader :method, :resource, :version, :headers, :params
  HEADER_PARAM = /\s*[\w.]+=(?:[\w.]+|"(?:[^"\\]|\\.)*")?\s*/.freeze

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
    pairs = params.split('&')
    pairs.map { |pair| pair.split('=', 2) }.to_h
  end

  def parse_body_params(lines)
    params = lines.drop(1).find_all { |line| line.include?('=') }
    return {} unless params

    params_to_h(params)
  end

  def parse_params(request)
    params = request.scan(HEADER_PARAM).map! do |s|
      key, value = s.strip.split('=', 2)
      value = value[1..-2].gsub(/\\(.)/, '\1') if value.start_with?('"')
      [key.downcase, value]
    end
    params.to_h
  end

  def params_to_h(params)
    pairable = params.filter { |p| p.include? '&' || p.match(/\;|\:/)}
    pairs = []
    pairs = pairable.map { |p| p.split('&') if p.include? '&' }.first if pairable.length > 0
    mapped_pairs = pairs.map { |pair| pair.split('=', 2) }.to_h

    unless mapped_pairs.empty?
      mapped_pairs.transform_values { |v| CGI.unescape(v) }
    else
      mapped_pairs
    end
  end

  def type(content_type)
    return nil unless content_type && !content_type.empty?
    split_pattern = /[;,]/
    type = content_type.split(split_pattern, 2).first
    type.rstrip!
    type.downcase!
    type
  end

  def content_type
    content_type = self.headers['Accept']
    content_type.nil? || content_type.empty? ? nil : content_type
  end

  def media_type
    type(content_type)
  end

  FORM_DATA_MEDIA_TYPES = [
    'application/x-www-form-urlencoded',
    'multipart/form-data'
  ]

  def form_data?
    type = media_type
    method = self.method

    (method == :post && type.nil?) || FORM_DATA_MEDIA_TYPES.include?(type)
  end
end

require_relative 'spec_helper'
require_relative '../lib/request'

request_string = File.read('example_requests/get-fruits-with-filter.request.txt')

describe 'Request' do

    describe 'Simple get-request' do
    
        it 'parses the http method' do
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request = Request.new(request_string)
            _(request.resource).must_equal "/fruits?type=bananas&minrating=4"
        end

        it 'parses the version' do
            request = Request.new(request_string)
            _(request.version).must_equal "HTTP/1.1"
        end

        it 'parses the headers' do
            correct_headers = {
                'Host' => 'fruits.com',
                'User-Agent' => 'ExampleBrowser/1.0',
                'Accept-Encoding' => 'gzip, deflate',
                'Accept' => '*/*'
            }
            request = Request.new(request_string)
            _(request.headers).must_equal correct_headers
        end

    end


end
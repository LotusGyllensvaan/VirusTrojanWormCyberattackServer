require_relative 'spec_helper'
require_relative '../lib/request'

request_string = File.read('./test/example_requests/get-index.request.txt')

describe 'Request' do

    describe 'Simple get-request' do
    
        it 'parses the http method' do
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request = Request.new(request_string)
            _(request.resource).must_equal "/"
        end

        it 'parses the version' do
            request = Request.new(request_string)
            _(request.version).must_equal "HTTP/1.1"
        end

    end


end
require_relative 'spec_helper'
require_relative '../lib/request'

describe 'Request' do

    describe 'get-index request' do
        request_string = File.read('example_requests\get-index.request.txt')

        it 'parses the http method' do
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request = Request.new(request_string)
            _(request.resource).must_equal '/'
        end

        it 'parses the version' do
            request = Request.new(request_string)
            _(request.version).must_equal 'HTTP/1.1'
        end

        it 'parses the headers' do
            correct_headers = {
                'Host' => 'developer.mozilla.org', 
                'Accept-Language' => 'fr'
            }
            request = Request.new(request_string)
            _(request.headers).must_equal correct_headers
        end

        it 'parses the params' do
            correct_params = {}
            request = Request.new(request_string)
            _(request.params).must_equal correct_params
        end

    end

    describe 'get-examples request' do
        request_string = File.read('example_requests\get-examples.request.txt')

        it 'parses the http method' do
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request = Request.new(request_string)
            _(request.resource).must_equal '/examples'
        end

        it 'parses the version' do
            request = Request.new(request_string)
            _(request.version).must_equal 'HTTP/1.1'
        end

        it 'parses the headers' do
            correct_headers = {
            'Host' => 'example.com',
            'User-Agent' => 'ExampleBrowser/1.0',
            'Accept-Encoding' => 'gzip, deflate',
            'Accept' => '*/*'
            }
            request = Request.new(request_string)
            _(request.headers).must_equal correct_headers
        end

        it 'parses the params' do
            correct_params = {}
            request = Request.new(request_string)
            _(request.params).must_equal correct_params
        end

    end

    describe 'get-fruits-with-filter request' do
        request_string = File.read('example_requests\get-fruits-with-filter.request.txt')

        it 'parses the http method' do
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request = Request.new(request_string)
            _(request.resource).must_equal '/fruits?type=bananas&minrating=4'
        end

        it 'parses the version' do
            request = Request.new(request_string)
            _(request.version).must_equal 'HTTP/1.1'
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

        it 'parses the params' do
            correct_params = {'type' => 'bananas', 'minrating' => '4'}
            request = Request.new(request_string)
            _(request.params).must_equal correct_params
        end

    end

    describe 'post-login request' do
        request_string = File.read('example_requests\post-login.request.txt')

        it 'parses the http method' do
            request = Request.new(request_string)
            _(request.method).must_equal :post
        end

        it 'parses the resource' do
            request = Request.new(request_string)
            _(request.resource).must_equal '/login'
        end

        it 'parses the version' do
            request = Request.new(request_string)
            _(request.version).must_equal 'HTTP/1.1'
        end

        it 'parses the headers' do
            correct_headers = {
                'Host' => 'foo.example',
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Content-Length' => '39'
            }
            request = Request.new(request_string)
            _(request.headers).must_equal correct_headers
        end

        it 'parses the params' do
            correct_params = {'username' => 'grillkorv', 'password' => 'verys3cret!'}
            request = Request.new(request_string)
            _(request.params).must_equal correct_params
        end

    end

end
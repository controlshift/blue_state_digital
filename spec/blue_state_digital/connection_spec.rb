require 'spec_helper'
require 'blue_state_digital/connection'
require 'timecop'

describe BlueStateDigital::Connection do
  let(:api_host) { 'enoch.bluestatedigital.com' }
  let(:api_id) { 'sfrazer' }
  let(:api_secret) { '7405d35963605dc36702c06314df85db7349613f' }
  let(:connection) { BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})}

  describe "#perform_request" do
    context 'POST' do
      it "should perform POST request" do
        timestamp = Time.now
        Timecop.freeze(timestamp) do
          api_call = '/somemethod'
          api_ts = timestamp.utc.to_i.to_s
          api_mac = connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '1', api_id: api_id, api_ts: api_ts })

          stub_url = "https://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=1"
          stub_request(:post, stub_url).with do |request|
            request.body.should == "a=b"
            request.headers['Accept'].should == 'text/xml'
            request.headers['Content-Type'].should == 'application/x-www-form-urlencoded'
            true
          end.to_return(body: "body")

          response = connection.perform_request(api_call, params = {}, method = "POST", body = "a=b")
          response.should == "body"
        end
      end

      it "should override Content-Type with param" do
        faraday_client = double(request: nil, response: nil, adapter: nil)
        headers = {}
        post_request = double(headers: headers, body: '', url: nil)
        post_request.stub(:body=)
        faraday_client.should_receive(:post).and_yield(post_request).and_return(post_request)
        Faraday.stub(:new).and_yield(faraday_client).and_return(faraday_client)
        connection = BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})

        connection.perform_request '/somemethod', { content_type: 'application/json' }, 'POST'

        headers.keys.should include('Content-Type')
        headers['Content-Type'].should == 'application/json'
      end

      it "should override Accept with param" do
        faraday_client = double(request: nil, response: nil, adapter: nil)
        headers = {}
        post_request = double(headers: headers, body: '', url: nil)
        post_request.stub(:body=)
        faraday_client.should_receive(:post).and_yield(post_request).and_return(post_request)
        Faraday.stub(:new).and_yield(faraday_client).and_return(faraday_client)
        connection = BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})

        connection.perform_request '/somemethod', { accept: 'application/json' }, 'POST'

        headers.keys.should include('Accept')
        headers['Accept'].should == 'application/json'
      end
    end

    it "should perform GET request" do
      timestamp = Time.now
      Timecop.freeze(timestamp) do
        api_call = '/somemethod'
        api_ts = timestamp.utc.to_i.to_s
        api_mac = connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '1', api_id: api_id, api_ts: api_ts })

        stub_url = "https://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=1"
        stub_request(:get, stub_url).to_return(body: "body")

        response = connection.perform_request(api_call, params = {})
        response.should == "body"
      end
    end
  end

  describe "perform_graph_request" do
    let(:faraday_client) { double(request: nil, response: nil, adapter: nil) }

    it "should perform Graph API request" do
      post_request = double
      post_request.should_receive(:url).with('/page/graph/rsvp/add', {param1: 'my_param', param2: 'my_other_param'})
      faraday_client.should_receive(:post).and_yield(post_request).and_return(post_request)
      Faraday.stub(:new).and_yield(faraday_client).and_return(faraday_client)
      connection = BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})

      connection.perform_graph_request('/rsvp/add', {param1: 'my_param', param2: 'my_other_param'}, 'POST')
    end
  end

  describe "#get_deferred_results" do
    it "should make a request" do
      connection.should_receive(:perform_request).and_return("foo")
      connection.get_deferred_results("deferred_id").should == "foo"
    end
  end

  describe "#compute_hmac" do
    it "should compute proper hmac hash" do
      params = { api_ver: '1', api_id: api_id, api_ts: '1272659462' }
      connection.compute_hmac('/page/api/circle/list_circles', '1272659462', params).should == '13e9de81bbdda506b6021579da86d3b6edea9755'
    end
  end
end

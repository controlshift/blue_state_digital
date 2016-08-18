require 'spec_helper'
require 'blue_state_digital/connection'
require 'timecop'

describe BlueStateDigital::Connection do
  let(:api_host) { 'enoch.bluestatedigital.com' }
  let(:api_id) { 'sfrazer' }
  let(:api_secret) { '7405d35963605dc36702c06314df85db7349613f' }
  let(:connection) { BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})}

  if Faraday::VERSION != "0.8.9"
    describe '#compute_hmac' do
      it "should not escape whitespaces on params" do
        timestamp = Time.parse('2014-01-01 00:00:00 +0000')
        Timecop.freeze(timestamp) do
          api_call = '/somemethod'
          api_ts = timestamp.utc.to_i.to_s
          expect(OpenSSL::HMAC).to receive(:hexdigest) do |digest, key, data|
            expect(digest).to eq('sha1')
            expect(key).to eq(api_secret)
            expect(data).to match(/name=string with multiple whitespaces/)
          end

          api_mac = connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '2', api_id: api_id, api_ts: api_ts, name: 'string with multiple whitespaces' })
        end
      end
    end
  end

  describe '#perform_request_raw' do
    let(:api_call) { '/somemethod' }
    let(:timestamp) { Time.now }
    let(:api_ts) { timestamp.utc.to_i.to_s }
    let(:api_mac) { connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '2', api_id: api_id, api_ts: api_ts }) }

    describe 'instrumentation' do
      before(:each) do
        Timecop.freeze(timestamp) do
          stub_url = "https://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=2"
          stub_request(:post, stub_url).with do |request|
            expect(request.body).to eq("a=b")
            expect(request.headers['Accept']).to eq('text/xml')
            expect(request.headers['Content-Type']).to eq('application/x-www-form-urlencoded')
            true
          end.to_return(body: "body")
        end
      end

      it 'should not instrument anything if instrumentation is nil' do
        expect(connection.instrumentation).to be_nil
        connection.perform_request(api_call, params = {}, method = "POST", body = "a=b")
      end

      context 'with instrumentation' do
        let(:instrumentation) do
          Proc.new do |stats|
            stats[:path]
          end
        end
        let(:connection) { BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret, instrumentation: instrumentation})}

        it 'should call if set to proc' do
          expect(instrumentation).to receive(:call).with({path: '/page/api/somemethod'})
          connection.perform_request(api_call, params = {}, method = "POST", body = "a=b")
        end
      end
    end
  end

  describe "#perform_request" do
    context 'POST' do
      it "should perform POST request" do
        timestamp = Time.now
        Timecop.freeze(timestamp) do
          api_call = '/somemethod'
          api_ts = timestamp.utc.to_i.to_s
          api_mac = connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '2', api_id: api_id, api_ts: api_ts })

          stub_url = "https://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=2"
          stub_request(:post, stub_url).with do |request|
            expect(request.body).to eq("a=b")
            expect(request.headers['Accept']).to eq('text/xml')
            expect(request.headers['Content-Type']).to eq('application/x-www-form-urlencoded')
            true
          end.to_return(body: "body")

          response = connection.perform_request(api_call, params = {}, method = "POST", body = "a=b")
          expect(response).to eq("body")
        end
      end

      context 'well stubbed' do
        before(:each) do
          faraday_client = double(request: nil, response: nil, adapter: nil, options: {})
          expect(faraday_client).to receive(:post).and_yield(post_request).and_return(post_request)
          allow(Faraday).to receive(:new).and_yield(faraday_client).and_return(faraday_client)
        end 

        let(:post_request) do
          pr = double(headers: headers, body: '', url: nil)
          allow(pr).to receive(:body=)
          options = double()
          allow(options).to receive(:timeout=)
          allow(pr).to receive(:options).and_return(options)
          pr
        end

        let(:headers) { {} } 

        it "should override Content-Type with param" do
          connection = BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})

          connection.perform_request '/somemethod', { content_type: 'application/json' }, 'POST'

          expect(headers.keys).to include('Content-Type')
          expect(headers['Content-Type']).to eq('application/json')
        end

        it "should override Accept with param" do
          connection = BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})

          connection.perform_request '/somemethod', { accept: 'application/json' }, 'POST'

          expect(headers.keys).to include('Accept')
          expect(headers['Accept']).to eq('application/json')
        end
      end
    end

    it "should perform PUT request" do
      timestamp = Time.now
      Timecop.freeze(timestamp) do
        api_call = '/somemethod'
        api_ts = timestamp.utc.to_i.to_s
        api_mac = connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '2', api_id: api_id, api_ts: api_ts })

        stub_url = "https://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=2"
        stub_request(:put, stub_url).with do |request|
          expect(request.body).to eq("a=b")
          expect(request.headers['Accept']).to eq('text/xml')
          expect(request.headers['Content-Type']).to eq('application/x-www-form-urlencoded')
          true
        end.to_return(body: "body")

        response = connection.perform_request(api_call, params = {}, method = "PUT", body = "a=b")
        expect(response).to eq("body")
      end
    end

    it "should perform GET request" do
      timestamp = Time.now
      Timecop.freeze(timestamp) do
        api_call = '/somemethod'
        api_ts = timestamp.utc.to_i.to_s
        api_mac = connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '2', api_id: api_id, api_ts: api_ts })

        stub_url = "https://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=2"
        stub_request(:get, stub_url).to_return(body: "body")

        response = connection.perform_request(api_call, params = {})
        expect(response).to eq("body")
      end
    end
  end

  describe "perform_graph_request" do
    let(:faraday_client) { double(request: nil, response: nil, adapter: nil) }

    it "should perform Graph API request" do
      post_request = double
      expect(post_request).to receive(:url).with('/page/graph/rsvp/add', {param1: 'my_param', param2: 'my_other_param'})
      expect(faraday_client).to receive(:post).and_yield(post_request).and_return(post_request)
      allow(Faraday).to receive(:new).and_yield(faraday_client).and_return(faraday_client)
      connection = BlueStateDigital::Connection.new({host: api_host, api_id: api_id, api_secret: api_secret})

      connection.perform_graph_request('/rsvp/add', {param1: 'my_param', param2: 'my_other_param'}, 'POST')
    end
  end

  describe "#get_deferred_results" do
    it "should make a request" do
      expect(connection).to receive(:perform_request).and_return("foo")
      expect(connection.get_deferred_results("deferred_id")).to eq("foo")
    end

    it 'should raise if timeout occurs' do
       expect(connection).to receive(:perform_request).and_return(nil)
       expect { connection.wait_for_deferred_result("deferred_id", 1) }.to raise_error(BlueStateDigital::DeferredResultTimeout)
    end

    it 'should not raise if successful' do
      expect(connection).to receive(:perform_request).and_return("foo")
      expect(connection.wait_for_deferred_result("deferred_id")).to eq("foo")
    end
  end

  describe "#compute_hmac" do
    it "should compute proper hmac hash" do
      params = { api_id: api_id, api_ts: '1272659462', api_ver: '2' }
      expect(connection.compute_hmac('/page/api/circle/list_circles', '1272659462', params)).to eq('c4a31bdaabef52d609cbb5b01213fb267af4e808')
    end
  end
end

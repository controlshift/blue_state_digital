require 'spec_helper'

describe BlueStateDigital::ErrorMiddleware do
  it 'should raise with the env' do
    expect do
      subject.on_complete(OpenStruct.new({status: 409, body: 'foo bar'}))
    end.to raise_error(Faraday::Error::ClientError, /foo bar/)
  end

  it 'should raise a typed exception' do
    expect do
      subject.on_complete(OpenStruct.new({status: 409, body: 'cons_group_id #279 does not exist'}))
    end.to raise_error(BlueStateDigital::ResourceDoesNotExist, /cons_group_id #279 does not exist/)
  end
end
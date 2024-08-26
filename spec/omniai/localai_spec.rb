# frozen_string_literal: true

RSpec.describe OmniAI::LocalAI do
  it 'has a version number' do
    expect(OmniAI::LocalAI::VERSION).not_to be_nil
  end

  it 'has a default host' do
    client = OmniAI::LocalAI::Client.new
    expect(client.host).to be('http://localhost:8080')
  end
end

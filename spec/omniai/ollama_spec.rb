# frozen_string_literal: true

RSpec.describe OmniAI::Ollama do
  it 'has a version number' do
    expect(OmniAI::Ollama::VERSION).not_to be_nil
  end

  it 'has a default host' do
    client = OmniAI::Ollama::Client.new
    expect(client.host).to be('http://localhost:11434')
  end
end

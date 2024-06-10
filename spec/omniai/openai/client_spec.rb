# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Client do
  subject(:client) { described_class.new }

  describe '#chat' do
    it 'proxies' do
      allow(OmniAI::OpenAI::Chat).to receive(:process!)
      client.chat('Hello!')
      expect(OmniAI::OpenAI::Chat).to have_received(:process!)
    end
  end

  describe '#connection' do
    it { expect(client.connection).to be_a(HTTP::Client) }
  end
end

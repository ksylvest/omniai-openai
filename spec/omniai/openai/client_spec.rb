# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    context 'with an api_key' do
      it { expect(described_class.new(api_key: '...')).to be_a(described_class) }
    end

    context 'without an api_key' do
      it { expect { described_class.new(api_key: nil) }.to raise_error(ArgumentError) }
    end
  end

  describe '#chat' do
    it 'proxies' do
      allow(OmniAI::OpenAI::Chat).to receive(:process!)
      client.chat('Hello!')
      expect(OmniAI::OpenAI::Chat).to have_received(:process!)
    end
  end

  describe '#transcribe' do
    it 'proxies' do
      allow(OmniAI::OpenAI::Transcribe).to receive(:process!)
      client.transcribe('file.ogg')
      expect(OmniAI::OpenAI::Transcribe).to have_received(:process!)
    end
  end

  describe '#speak' do
    it 'proxies' do
      allow(OmniAI::OpenAI::Speak).to receive(:process!)
      client.speak('Hello!')
      expect(OmniAI::OpenAI::Speak).to have_received(:process!)
    end
  end

  describe '#connection' do
    it { expect(client.connection).to be_a(HTTP::Client) }
  end
end

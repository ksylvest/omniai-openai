# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat do
  subject(:chat) { described_class.new(client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  describe '#completion' do
    subject(:completion) { chat.completion(prompt, model:, temperature:) }

    let(:model) { described_class::Model::GPT_4O }
    let(:temperature) { 0.7 }

    context 'with a string prompt' do
      let(:prompt) { 'Tell me a joke!' }

      before do
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .with(body: {
            messages: [{ role: 'user', content: prompt }],
            model:,
            temperature:,
          })
          .to_return_json(body: {
            choices: [{
              index: 0,
              message: {
                role: 'assistant',
                content: 'Two elephants fall off a cliff. Boom! Boom!',
              },
            }],
          })
      end

      it { expect(completion.choice.message.role).to eql('assistant') }
      it { expect(completion.choice.message.content).to eql('Two elephants fall off a cliff. Boom! Boom!') }
    end

    context 'with an array prompt' do
      let(:prompt) do
        [
          { role: OmniAI::OpenAI::Chat::Role::SYSTEM, content: 'You are a helpful assistant.' },
          { role: OmniAI::OpenAI::Chat::Role::USER, content: 'What is the capital of Canada?' },
        ]
      end

      before do
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .with(body: {
            messages: [
              { role: 'system', content: 'You are a helpful assistant.' },
              { role: 'user', content: 'What is the capital of Canada?' },
            ],
            model:,
            temperature:,
          })
          .to_return_json(body: {
            choices: [{
              index: 0,
              message: {
                role: 'assistant',
                content: 'The capital of Canada is Ottawa.',
              },
            }],
          })
      end

      it { expect(completion.choice.message.role).to eql('assistant') }
      it { expect(completion.choice.message.content).to eql('The capital of Canada is Ottawa.') }
    end
  end
end

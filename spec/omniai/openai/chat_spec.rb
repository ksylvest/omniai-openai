# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe ".process!" do
    subject(:completion) { described_class.process!(prompt, client:, model:) }

    let(:model) { described_class::DEFAULT_MODEL }

    context "with a basic prompt" do
      let(:prompt) { "Tell me a joke!" }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Tell me a joke!" }],
            }],
            model:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "Two elephants fall off a cliff. Boom! Boom!" }],
            }],
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end

    context "with an advanced prompt" do
      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.system("You are a helpful assistant.")
          prompt.user("What is the capital of Canada?")
        end
      end

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            instructions: "You are a helpful assistant.",
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "What is the capital of Canada?" }],
            }],
            model:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "The capital of Canada is Ottawa." }],
            }],
          })
      end

      it { expect(completion.text).to eql("The capital of Canada is Ottawa.") }
    end

    context "with a temperature using a model that supports" do
      subject(:completion) { described_class.process!(prompt, client:, model:, temperature:) }

      let(:model) { described_class::Model::GPT_4O_MINI }
      let(:prompt) { "Pick a number between 1 and 5." }
      let(:temperature) { 2.0 }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Pick a number between 1 and 5." }],
            }],
            model:,
            temperature:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "3" }],
            }],
          })
      end

      it { expect(completion.text).to eql("3") }
    end

    context "with a temperature using a model that does not support" do
      subject(:completion) { described_class.process!(prompt, client:, model:, temperature:) }

      let(:model) { described_class::Model::O3_MINI }
      let(:prompt) { "Pick a number between 1 and 5." }
      let(:temperature) { 2.0 }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Pick a number between 1 and 5." }],
            }],
            model:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "3" }],
            }],
          })
      end

      it { expect(completion.text).to eql("3") }
    end

    context "when formatting as JSON" do
      subject(:completion) { described_class.process!(prompt, client:, model:, format: :json) }

      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.system(OmniAI::Chat::JSON_PROMPT)
          prompt.user("What is the name of the dummer for the Beatles?")
        end
      end

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            instructions: OmniAI::Chat::JSON_PROMPT,
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "What is the name of the dummer for the Beatles?" }],
            }],
            model:,
            text: { format: { type: "json_object" } },
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: '{ "name": "Ringo" }' }],
            }],
          })
      end

      it { expect(completion.text).to eql('{ "name": "Ringo" }') }
    end

    context "when streaming" do
      subject(:completion) { described_class.process!(prompt, client:, model:, stream:) }

      let(:prompt) { "Tell me a story." }
      let(:stream) { proc { |chunk| chunks << chunk } }
      let(:chunks) { [] }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Tell me a story." }],
            }],
            model:,
            stream: true,
          })
          .to_return(body: <<~STREAM)
            event: response.output_text.delta
            data: #{JSON.generate({
              delta: 'Hello',
            })}

            event: response.output_text.delta
            data: #{JSON.generate({
              type: 'response.output_text.delta',
              delta: ' ',
            })}

            event: response.output_text.delta
            data: #{JSON.generate({
              delta: 'World',
            })}

            event: response.completed
            data: #{JSON.generate({
              response: {
                output: [{
                  type: 'message',
                  role: 'assistant',
                  content: [{ type: 'output_text', text: 'Hello World' }],
                }],
              },
            })}

            data: [DONE]
          STREAM
      end

      it { expect(completion.text).to eql("Hello World") }
    end

    context "when using files / URLs" do
      let(:io) { Tempfile.new }

      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.user do |message|
            message.text("What are these photos of?")
            message.url("https://localhost/cat.jpg", "image/jpeg")
            message.url("https://localhost/dog.jpg", "image/jpeg")
            message.file(io, "image/jpeg")
          end
        end
      end

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [
              {
                role: "user",
                content: [
                  { type: "input_text", text: "What are these photos of?" },
                  { type: "input_image", image_url: "https://localhost/cat.jpg" },
                  { type: "input_image", image_url: "https://localhost/dog.jpg" },
                  { type: "input_image", image_data: "", filename: File.basename(io) },
                ],
              },
            ],
            model:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "They are a photo of a cat and a photo of a dog." }],
            }],
          })
      end

      it { expect(completion.text).to eql("They are a photo of a cat and a photo of a dog.") }
    end

    context "with a reasoning option" do
      subject(:completion) { described_class.process!(prompt, client:, model:, reasoning:) }

      let(:model) { described_class::Model::GPT_5_1 }
      let(:prompt) { "Tell me a joke!" }
      let(:reasoning) { { effort: "medium" } }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Tell me a joke!" }],
            }],
            model:,
            reasoning:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "Two elephants fall off a cliff. Boom! Boom!" }],
            }],
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end

    context "with thinking: true option" do
      subject(:completion) { described_class.process!(prompt, client:, model:, thinking: true) }

      let(:model) { described_class::Model::GPT_5_1 }
      let(:prompt) { "Tell me a joke!" }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Tell me a joke!" }],
            }],
            model:,
            reasoning: { effort: "high", summary: "auto" },
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "Two elephants fall off a cliff. Boom! Boom!" }],
            }],
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end

    context "with thinking: { effort: 'low' } option" do
      subject(:completion) { described_class.process!(prompt, client:, model:, thinking: { effort: "low" }) }

      let(:model) { described_class::Model::GPT_5_1 }
      let(:prompt) { "Tell me a joke!" }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Tell me a joke!" }],
            }],
            model:,
            reasoning: { effort: "low", summary: "auto" },
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "Two elephants fall off a cliff. Boom! Boom!" }],
            }],
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end

    context "with a text option" do
      subject(:completion) { described_class.process!(prompt, client:, model:, text:) }

      let(:model) { described_class::Model::GPT_5_1 }
      let(:prompt) { "Tell me a joke!" }
      let(:text) { { verbosity: "medium" } }

      before do
        stub_request(:post, "https://api.openai.com/v1/responses")
          .with(body: {
            input: [{
              role: "user",
              content: [{ type: "input_text", text: "Tell me a joke!" }],
            }],
            model:,
            text:,
          })
          .to_return_json(body: {
            output: [{
              type: "message",
              role: "assistant",
              content: [{ type: "output_text", text: "Two elephants fall off a cliff. Boom! Boom!" }],
            }],
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end
  end
end

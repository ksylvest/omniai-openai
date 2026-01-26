# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat::Stream do
  subject(:stream) { described_class.new(chunks:) }

  describe ".stream!" do
    subject(:stream!) { stream.stream! { |delta| deltas << delta } }

    let(:deltas) { [] }

    context "when parsing text chunks" do
      let(:chunks) do
        [
          "event: response.output_text.delta\ndata: #{JSON.generate({ delta: 'Hello' })}\n\n",
          "event: response.output_text.delta\ndata: #{JSON.generate({ delta: ' ' })}\n\n",
          "event: response.output_text.delta\ndata: #{JSON.generate({ delta: 'World' })}\n\n",
          "event: response.completed\ndata: #{JSON.generate({
            response: {
              output: [{
                type: 'message',
                role: 'assistant',
                content: [{ type: 'output_text', text: 'Hello World' }],
              }],
            },
          })}\n\n",
        ]
      end

      let(:expected_response) do
        { "output" => [{ "type" => "message", "role" => "assistant",
                         "content" => [{ "type" => "output_text", "text" => "Hello World" }], }] }
      end

      it "returns the completed response" do
        expect(stream!).to eql(expected_response)
      end

      it "yields multiple times" do
        stream!
        expect(deltas.map(&:text)).to eql(["Hello", " ", "World"])
      end
    end

    context "when chunks split a multi-byte UTF-8 character" do
      let(:chunks) do
        # 😀 is 4 bytes: F0 9F 98 80
        # Split after first 2 bytes to create invalid UTF-8 sequence
        [
          (+"event: response.output_text.delta\ndata: {\"delta\":\"Hello \xF0\x9F").force_encoding("UTF-8"),
          "\x98\x80\"}\n\nevent: response.completed\ndata: #{JSON.generate({
            response: {
              output: [{
                type: 'message',
                role: 'assistant',
                content: [{ type: 'output_text', text: 'Hello 😀' }],
              }],
            },
          })}\n\n".force_encoding("UTF-8"),
        ]
      end

      it "handles split UTF-8 without raising an error" do
        expect { stream! }.not_to raise_error
      end

      it "returns the completed response with correct text" do
        expect(stream!["output"].first["content"].first["text"]).to eq("Hello 😀")
      end
    end
  end
end

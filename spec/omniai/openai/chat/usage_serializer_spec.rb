# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat::UsageSerializer do
  let(:context) { OmniAI::OpenAI::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    context "with a reasoning breakdown" do
      # Captured: gpt-5.6-luna, POST /v1/responses, thinking effort "high", 2026-08-20.
      let(:data) do
        {
          "input_tokens" => 46,
          "input_tokens_details" => { "cache_write_tokens" => 0, "cached_tokens" => 0 },
          "output_tokens" => 1296,
          "output_tokens_details" => { "reasoning_tokens" => 444 },
          "total_tokens" => 1342,
        }
      end

      it { expect(deserialize).to be_a(OmniAI::Chat::Usage) }
      it { expect(deserialize.input_tokens).to be(46) }
      it { expect(deserialize.thinking_tokens).to be(444) }
      it { expect(deserialize.total_tokens).to be(1342) }

      it "leaves output_tokens as reported, because OpenAI already counts reasoning in it" do
        expect(deserialize.output_tokens).to be(1296)
      end

      it "keeps thinking_tokens a subset of output_tokens" do
        expect(deserialize.thinking_tokens).to be <= deserialize.output_tokens
      end

      it "satisfies input + output == total on the captured response" do
        expect(deserialize.input_tokens + deserialize.output_tokens).to eq(deserialize.total_tokens)
      end
    end

    context "with a reasoning breakdown reporting zero" do
      # The captured shape above with the reported value changed to zero — the value is constructed, the shape is
      # captured. Pins that a wire-reported zero is preserved rather than collapsed to nil.
      let(:data) do
        {
          "input_tokens" => 46,
          "output_tokens" => 1296,
          "output_tokens_details" => { "reasoning_tokens" => 0 },
          "total_tokens" => 1342,
        }
      end

      it "keeps a wire-reported zero, rather than collapsing it to nil" do
        expect(deserialize.thinking_tokens).to be(0)
      end
    end

    context "without a reasoning breakdown" do
      let(:data) { { "input_tokens" => 2, "output_tokens" => 3, "total_tokens" => 5 } }

      it "leaves thinking_tokens nil rather than reporting zero" do
        expect(deserialize.thinking_tokens).to be_nil
      end
    end

    context "with Chat Completions vocabulary from the previous API generation" do
      # Captured evidence: the /v1/responses usage object reported input_tokens, input_tokens_details,
      # output_tokens, output_tokens_details and total_tokens on 2026-08-20 — `completion_tokens_details` was
      # absent entirely. Asserting the miss keeps a future reader from re-adding a path for a shape this gem
      # never receives.
      let(:data) do
        {
          "input_tokens" => 46,
          "output_tokens" => 1296,
          "completion_tokens_details" => { "reasoning_tokens" => 444 },
        }
      end

      it "does not read it" do
        expect(deserialize.thinking_tokens).to be_nil
      end
    end

    context "when round-tripping a base-serialized payload" do
      # 'Usage#serialize' emits base's own 'thinking_tokens' key and no vendor container. Deserializing that back
      # under this context must not clobber the parsed value with nil.
      let(:data) do
        OmniAI::Chat::Usage.new(input_tokens: 46, output_tokens: 1296, total_tokens: 1342, thinking_tokens: 444)
          .serialize(context:)
          .transform_keys(&:to_s)
      end

      it "preserves thinking_tokens" do
        expect(deserialize.thinking_tokens).to be(444)
      end
    end
  end
end

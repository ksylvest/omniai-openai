# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat::UsageSerializer do
  let(:context) { OmniAI::OpenAI::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    # NOTE: these payloads are derived from the documented Responses API `usage` shape, not captured from a live
    # response. No OpenAI credentials were available when this was written. Treat the key names as
    # documentation-derived.

    context "without a reasoning breakdown" do
      let(:data) { { "input_tokens" => 2, "output_tokens" => 3, "total_tokens" => 5 } }

      it { expect(deserialize).to be_a(OmniAI::Chat::Usage) }
      it { expect(deserialize.input_tokens).to be(2) }
      it { expect(deserialize.output_tokens).to be(3) }
      it { expect(deserialize.total_tokens).to be(5) }

      it "leaves thinking_tokens nil rather than reporting zero" do
        expect(deserialize.thinking_tokens).to be_nil
      end
    end

    context "with a reasoning breakdown" do
      let(:data) do
        {
          "input_tokens" => 2,
          "output_tokens" => 9,
          "total_tokens" => 11,
          "output_tokens_details" => { "reasoning_tokens" => 6 },
        }
      end

      it { expect(deserialize.thinking_tokens).to be(6) }

      it "leaves output_tokens as reported, because OpenAI already counts reasoning in it" do
        expect(deserialize.output_tokens).to be(9)
      end

      it "keeps thinking_tokens a subset of output_tokens" do
        expect(deserialize.thinking_tokens).to be <= deserialize.output_tokens
      end
    end

    context "with a reasoning breakdown reporting zero" do
      let(:data) do
        {
          "input_tokens" => 2,
          "output_tokens" => 3,
          "total_tokens" => 5,
          "output_tokens_details" => { "reasoning_tokens" => 0 },
        }
      end

      it "keeps a wire-reported zero, rather than collapsing it to nil" do
        expect(deserialize.thinking_tokens).to be(0)
      end
    end

    context "with Chat Completions vocabulary from the previous API generation" do
      # This gem targets `/responses`, which does not send `completion_tokens_details`. Asserting the miss keeps a
      # future reader from re-adding a path for a shape this gem never receives.
      let(:data) do
        {
          "input_tokens" => 2,
          "output_tokens" => 9,
          "completion_tokens_details" => { "reasoning_tokens" => 6 },
        }
      end

      it "does not read it" do
        expect(deserialize.thinking_tokens).to be_nil
      end
    end
  end
end

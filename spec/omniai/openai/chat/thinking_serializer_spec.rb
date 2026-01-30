# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat::ThinkingSerializer do
  describe ".serialize" do
    subject(:serialize) { described_class.serialize(thinking) }

    let(:thinking) { OmniAI::Chat::Thinking.new("The user wants to know about X.") }

    it { is_expected.to eql(type: "reasoning", summary: "The user wants to know about X.") }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data) }

    context "with a string summary" do
      let(:data) { { "type" => "reasoning", "summary" => "The user wants to know about X." } }

      it { is_expected.to be_a(OmniAI::Chat::Thinking) }

      it "extracts the thinking text" do
        expect(deserialize.thinking).to eq("The user wants to know about X.")
      end
    end

    context "with an array summary (Responses API format)" do
      let(:data) do
        {
          "type" => "reasoning",
          "summary" => [
            { "type" => "summary_text", "text" => "First thought." },
            { "type" => "summary_text", "text" => "Second thought." },
          ],
        }
      end

      it { is_expected.to be_a(OmniAI::Chat::Thinking) }

      it "joins the summary_text items with newlines" do
        expect(deserialize.thinking).to eq("First thought.\nSecond thought.")
      end
    end

    context "with a thinking field fallback" do
      let(:data) { { "thinking" => "Some thinking content." } }

      it { is_expected.to be_a(OmniAI::Chat::Thinking) }

      it "extracts the thinking text" do
        expect(deserialize.thinking).to eq("Some thinking content.")
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Chat::ResponseSerializer do
  let(:context) { OmniAI::OpenAI::Chat::CONTEXT }

  describe ".deserialize finish_reason mapping" do
    subject(:finish_reason) { described_class.deserialize(data, context:).finish_reason }

    let(:output) do
      [{ "type" => "message", "role" => "assistant", "content" => [{ "type" => "output_text", "text" => "Hi" }] }]
    end

    context "when mapping the response-level status" do
      let(:data) { { "output" => output, "status" => status } }

      {
        "completed" => :stop,
        "incomplete" => :other,
        "failed" => :other,
      }.each do |raw, expected|
        context "when status is #{raw.inspect}" do
          let(:status) { raw }

          it "normalizes the reason" do
            expect(finish_reason.reason).to eq(expected)
          end

          it "preserves the verbatim value" do
            expect(finish_reason.value).to eq(raw)
          end
        end
      end
    end

    context "when incomplete_details.reason is present it wins over status" do
      let(:data) do
        { "output" => output, "status" => "incomplete", "incomplete_details" => { "reason" => reason } }
      end

      {
        "max_output_tokens" => :length,
        "content_filter" => :filter,
      }.each do |raw, expected|
        context "when reason is #{raw.inspect}" do
          let(:reason) { raw }

          it "normalizes the reason" do
            expect(finish_reason.reason).to eq(expected)
          end

          it "preserves the verbatim value" do
            expect(finish_reason.value).to eq(raw)
          end
        end
      end
    end

    context "when neither status nor incomplete_details is present" do
      let(:data) { { "output" => output } }

      it { is_expected.to be_nil }
    end
  end
end

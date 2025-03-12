# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Usage::Cost do
  before do
    OmniAI::OpenAI.configure do |config|
      config.admin_api_key = "fake_admin_key"
    end
  end

  let(:params) do
    {
      start_time: 1_739_112_382,
      end_time: 1_741_704_400,
      bucket_width: nil,
      project_ids: ["proj_6fLLCZmchmiqHfzSKWYVMUtr"],
      group_by: ["project_id"],
      limit: 100,
      page: nil,
    }
  end

  describe ".get" do
    subject(:cost_response) { described_class.get(**params) }

    context "with an OK response" do
      let(:response_body) do
        {
          "total_cost" => 123.45,
          "currency" => "USD",
          "breakdown" => [
            { "project_id" => "proj_6fLLCZmchmiqHfzSKWYVMUtr", "cost" => 123.45 },
          ],
        }
      end

      before do
        stub_request(:get, %r{https://api\.openai\.com/v1/organization/costs\?})
          .with(query: hash_including(
            "start_time" => params[:start_time].to_s,
            "end_time" => params[:end_time].to_s,
            "project_ids" => params[:project_ids].join(","),
            "group_by" => params[:group_by].join(","),
            "limit" => params[:limit].to_s
          ))
          .to_return(
            body: response_body.to_json,
            status: 200,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns the parsed response" do
        expect(cost_response).to eq(response_body)
      end
    end

    context "with an error response" do
      before do
        stub_request(:get, %r{https://api\.openai\.com/v1/organization/costs\?})
          .to_return(
            body: { "error" => "Not Found" }.to_json,
            status: 404,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises an HTTPError" do
        expect { cost_response }.to raise_error(OmniAI::HTTPError)
      end
    end

    context "with invalid parameters" do
      subject(:cost_response) { described_class.get(**invalid_params) }

      let(:invalid_params) do
        # Passing strings instead of arrays for project_ids and group_by.
        params.merge(
          project_ids: "not-an-array",
          group_by: "not-an-array"
        )
      end

      it "raises a NoMethodError" do
        expect { cost_response }.to raise_error(ArgumentError)
      end
    end
  end
end

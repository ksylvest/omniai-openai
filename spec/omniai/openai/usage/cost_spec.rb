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
      project_ids: ["proj_1234"],
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
          "object" => "page",
          "has_more" => false,
          "next_page" => nil,
          "data" => [
            {
              "object" => "bucket",
              "start_time" => 1_739_112_382,
              "end_time" => 1_741_704_400,
              "results" => [
                {
                  "object" => "organization.costs.result",
                  "amount" => {
                    "value" => 0.06,
                    "currency" => "usd",
                  },
                  "line_item" => nil,
                  "project_id" => "proj_1234",
                },
              ],
            },
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

    describe "with an unhandled error" do
      context "when the admin API key is missing" do
        before do
          stub_request(:get, %r{https://api\.openai\.com/v1/organization/costs\?})
            .to_return(
              body: {
                "error" => {
                  "message" => error_message,
                  "type" => "invalid_request_error",
                  "param" => nil,
                  "code" => nil,
                },
              }.to_json,
              status: 401,
              headers: { "Content-Type" => "application/json" }
            )
        end

        let(:error_message) do
          "You didn't provide an API key. You need to provide your API key " \
            "in an Authorization header using Bearer auth (i.e. Authorization: Bearer YOUR_KEY). " \
            "You can obtain an API key from https://platform.openai.com/account/api-keys."
        end

        it "raises an error" do
          expect { described_class.get(**params) }
            .to raise_error(OmniAI::HTTPError, a_string_including(error_message))
        end
      end

      context "when the admin API key is invalid" do
        before do
          stub_request(:get, %r{https://api\.openai\.com/v1/organization/costs\?})
            .to_return(
              body: {
                "error" => {
                  "message" => error_message,
                  "type" => "invalid_request_error",
                  "param" => nil,
                  "code" => "invalid_api_key",
                },
              }.to_json,
              status: 401,
              headers: { "Content-Type" => "application/json" }
            )
        end

        let(:error_message) do
          "Incorrect API key provided: sk-invalid***. You can find your API key " \
            "at https://platform.openai.com/account/api-keys."
        end

        it "raises an error with the correct details" do
          expect { described_class.get(**params) }
            .to raise_error(OmniAI::HTTPError, a_string_including(error_message, "invalid_api_key"))
        end
      end
    end
  end
end

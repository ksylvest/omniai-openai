# frozen_string_literal: true

module OmniAI
  module OpenAI
    module Usage
      # An OpenAI cost implementation.
      class Cost
        # @!attribute [r] start_time
        #   @return [Time]
        attr_reader :start_time

        # @!attribute [r] end_time
        #   @return [Time, nil]
        attr_reader :end_time

        # @!attribute [r] bucket_width
        #   @return [String, nil]
        attr_reader :bucket_width

        # @!attribute [r] project_ids
        #   @return [Array<String>, nil]
        attr_reader :project_ids

        # @!attribute [r] group_by
        #   @return [Array<String>, nil]
        attr_reader :group_by

        # @!attribute [r] limit
        #   @return [Integer, nil]
        attr_reader :limit

        # @!attribute [r] page
        #   @return [Integer, nil]
        attr_reader :page

        # @param start_time [Time]
        # @param end_time [Time, nil] optional
        # @param bucket_width [String, nil] optional
        # @param project_ids [Array<String>, nil] optional
        # @param group_by [Array<String>, nil] optional
        # @param limit [Integer, nil] optional
        # @param page [Integer, nil] optional
        def initialize(
          start_time:,
          end_time: nil,
          bucket_width: nil,
          project_ids: nil,
          group_by: nil,
          limit: nil,
          page: nil
        )
          @start_time = start_time
          @end_time = end_time
          @bucket_width = bucket_width
          @project_ids = project_ids
          @group_by = group_by
          @limit = limit
          @page = page
          @client = OmniAI::OpenAI::Client.new(api_key: OmniAI::OpenAI.config.admin_api_key)

          validate_array_params!
        end

        # @param response [HTTP::Response]
        def self.get(**args)
          new(**args).get
        end

        # @param response [HTTP::Response]
        def get
          response = @client.connection
            .accept(:json)
            .get("/#{OmniAI::OpenAI::Client::VERSION}/organization/costs?#{request_params}")

          raise HTTPError, response.flush unless response.status.ok?

          response.parse
        end

      private

        # @return [String]
        def request_params
          params = {
            start_time:,
            end_time:,
            bucket_width:,
            project_ids: project_ids&.join(","),
            group_by: group_by&.join(","),
            limit:,
            page:,
          }.compact

          URI.encode_www_form(params)
        end

        # @raise [ArgumentError]
        # @return [void]
        def validate_array_params!
          raise ArgumentError, "project_ids must be an Array" if project_ids && !project_ids.is_a?(Array)

          return unless group_by && !group_by.is_a?(Array)

          raise ArgumentError, "group_by must be an Array"
        end
      end
    end
  end
end

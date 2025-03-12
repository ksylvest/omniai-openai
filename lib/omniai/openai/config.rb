# frozen_string_literal: true

module OmniAI
  module OpenAI
    # Configuration for OpenAI.
    class Config < OmniAI::Config
      DEFAULT_HOST = "https://api.openai.com"

      # @!attribute [rw] organization
      #   @return [String, nil] passed as `OpenAI-Organization` if specified
      attr_accessor :organization

      # @!attribute [rw] project
      #   @return [String, nil] passed as `OpenAI-Organization` if specified
      attr_accessor :project

      # @!attribute [rw] admin_api_key
      #   @return [String, nil] passed as `OpenAI-Admin-Key` if specified
      attr_accessor :admin_api_key

      # @param api_key [String, nil] optional - defaults to `ENV['OPENAI_API_KEY']`
      # @param host [String, nil] optional - defaults to ENV['OPENAI_HOST'] w/ fallback to `DEFAULT_HOST`
      # @param organization [String, nil] optional - defaults to `ENV['OPENAI_ORGANIZATION']`
      # @param project [String, nil] optional - defaults to `ENV['OPENAI_PROJECT']`
      # @param logger [Logger, nil] optional
      # @param timeout [Integer, Hash, nil] optional
      # @param admin_api_key [String, nil] optional - defaults to `ENV['OPENAI_ADMIN_API_KEY']`
      def initialize(
        api_key: ENV.fetch("OPENAI_API_KEY", nil),
        admin_api_key: ENV.fetch("OPENAI_ADMIN_API_KEY", nil),
        host: ENV.fetch("OPENAI_HOST", DEFAULT_HOST),
        organization: ENV.fetch("OPENAI_ORGANIZATION", nil),
        project: ENV.fetch("OPENAI_PROJECT", nil),
        logger: nil,
        timeout: nil
      )
        super(api_key:, host:, logger:, timeout:)

        @admin_api_key = admin_api_key
        @organization = organization
        @project = project
      end
    end
  end
end

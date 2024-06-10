# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::OpenAI::Client.new(api_key: '...')
    #
    # w/ ENV['OPENAI_API_KEY']:
    #
    #   ENV['OPENAI_API_KEY'] = '...'
    #   client = OmniAI::OpenAI::Client.new
    #
    # w/ config:
    #
    #   OmniAI::OpenAI.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::OpenAI::Client.new
    class Client < OmniAI::Client
      VERSION = 'v1'

      # @param api_key [String] optional - defaults to `OmniAI::OpenAI.config.api_key`
      # @param project_id [String] optional - defaults to `OmniAI::OpenAI.config.project`
      # @param organization_id [String] optional - defaults to `OmniAI::OpenAI.config.organization`
      # @param logger [Logger] optional - defaults to `OmniAI::OpenAI.config.logger`
      def initialize(
        api_key: OmniAI::OpenAI.config.api_key,
        organization: OmniAI::OpenAI.config.organization,
        project: OmniAI::OpenAI.config.project,
        logger: OmniAI::OpenAI.config.logger,
        host: OmniAI::OpenAI.config.host
      )
        raise(ArgumentError, %(ENV['OPENAI_API_KEY'] must be defined or `api_key` must be passed)) if api_key.nil?

        super(api_key:, logger:)

        @organization = organization
        @project = project
        @host = host
      end

      # @return [HTTP::Client]
      def connection
        @connection ||= begin
          http = HTTP.auth("Bearer #{api_key}").persistent(@host)
          http = http.headers('OpenAI-Organization': @organization) if @organization
          http = http.headers('OpenAI-Project': @project) if @project
          http
        end
      end

      # @raise [OmniAI::Error]
      #
      # @param messages [String, Array, Hash]
      # @param model [String] optional
      # @param format [Symbol] optional :text or :json
      # @param temperature [Float, nil] optional
      # @param stream [Proc, nil] optional
      #
      # @return [OmniAI::Chat::Completion]
      def chat(messages, model: Chat::Model::GPT_4O, temperature: nil, format: nil, stream: nil)
        Chat.process!(messages, model:, temperature:, format:, stream:, client: self)
      end
    end
  end
end

# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI chat implementation.
    #
    # Usage:
    #
    #   completion = OmniAI::OpenAI::Chat.process!(client: client) do |prompt|
    #     prompt.system('You are an expert in the field of AI.')
    #     prompt.user('What are the biggest risks of AI?')
    #   end
    #   completion.choice.message.content # '...'
    class Chat < OmniAI::Chat
      JSON_RESPONSE_FORMAT = { type: "json_object" }.freeze
      DEFAULT_STREAM_OPTIONS = { include_usage: ENV.fetch("OMNIAI_STREAM_USAGE", "on").eql?("on") }.freeze

      module Model
        GPT_4O = "gpt-4o"
        GPT_4O_MINI = "gpt-4o-mini"
        GPT_4 = "gpt-4"
        GPT_4_TURBO = "gpt-4-turbo"
        GPT_3_5_TURBO = "gpt-3.5-turbo"
        O1_MINI = "o1-mini"
        O3_MINI = "o3-mini"
        O1_PREVIEW = "o1-preview"
        O1 = "o1"
      end

      DEFAULT_MODEL = Model::GPT_4O

    protected

      # @return [Hash]
      def payload
        OmniAI::OpenAI.config.chat_options.merge({
          messages: @prompt.serialize,
          model: @model,
          response_format: (JSON_RESPONSE_FORMAT if @format.eql?(:json)),
          stream: stream? || nil,
          stream_options: (DEFAULT_STREAM_OPTIONS if stream?),
          temperature: @temperature,
          tools: (@tools.map(&:serialize) if @tools&.any?),
        }).compact
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/chat/completions"
      end
    end
  end
end

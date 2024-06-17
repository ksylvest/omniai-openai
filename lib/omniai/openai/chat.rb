# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI chat implementation.
    class Chat < OmniAI::Chat
      JSON_RESPONSE_FORMAT = { type: 'json_object' }.freeze

      module Model
        GPT_4O = 'gpt-4o'
        GPT_4 = 'gpt-4'
        GPT_4_TURBO = 'gpt-4-turbo'
        GPT_3_5_TURBO = 'gpt-3.5-turbo'
      end

      DEFAULT_MODEL = Model::GPT_4O

      protected

      # @return [Hash]
      def payload
        OmniAI::OpenAI.config.chat_options.merge({
          messages:,
          model: @model,
          stream: @stream.nil? ? nil : !@stream.nil?,
          temperature: @temperature,
          response_format: (JSON_RESPONSE_FORMAT if @format.eql?(:json)),
        }).compact
      end

      # @return [String]
      def path
        "/#{OmniAI::OpenAI::Client::VERSION}/chat/completions"
      end
    end
  end
end

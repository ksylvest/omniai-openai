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
      JSON_RESPONSE_FORMAT = { type: 'json_object' }.freeze

      module Model
        GPT_4O = 'gpt-4o'
        GPT_4O_MINI = 'gpt-4o-mini'
        GPT_4 = 'gpt-4'
        GPT_4_TURBO = 'gpt-4-turbo'
        GPT_3_5_TURBO = 'gpt-3.5-turbo'
      end

      DEFAULT_MODEL = Model::GPT_4O

      protected

      # @return [Hash]
      def payload
        OmniAI::OpenAI.config.chat_options.merge({
          messages: @prompt.serialize,
          model: @model,
          stream: @stream.nil? ? nil : !@stream.nil?,
          temperature: @temperature,
          response_format: (JSON_RESPONSE_FORMAT if @format.eql?(:json)),
          tools: (@tools.map(&:serialize) if @tools&.any?),
        }).compact
      end

      # @return [String]
      def path
        "/#{OmniAI::OpenAI::Client::VERSION}/chat/completions"
      end
    end
  end
end

# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI chat implementation.
    #
    # Usage:
    #
    #   chat = OmniAI::OpenAI::Chat.new(client: client)
    #   chat.completion('Tell me a joke.')
    #   chat.completion(['Tell me a joke.'])
    #   chat.completion({ role: 'user', content: 'Tell me a joke.' })
    #   chat.completion([{ role: 'system', content: 'Tell me a joke.' }])
    class Chat < OmniAI::Chat
      module Model
        GPT_4O = 'gpt-4o'
        GPT_4 = 'gpt-4'
        GPT_4_TURBO = 'gpt-4-turbo'
        GPT_3_5_TURBO = 'gpt-3.5-turbo'
      end

      module Role
        ASSISTANT = 'assistant'
        USER = 'user'
        SYSTEM = 'system'
      end

      # @raise [OmniAI::Error]
      #
      # @param prompt [String]
      # @param model [String] optional
      # @param format [Symbol] optional :text or :json
      # @param temperature [Float, nil] optional
      # @param stream [Proc, nil] optional
      #
      # @return [OmniAI::OpenAi::Chat::Response]
      def completion(messages, model: Model::GPT_4O, temperature: nil, format: nil, stream: nil)
        request = Request.new(client: @client, messages:, model:, temperature:, format:, stream:)
        request.process!
      end
    end
  end
end

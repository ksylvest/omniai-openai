# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI embed implementation.
    #
    # Usage:
    #
    #   input = "..."
    #   response = OmniAI::OpenAI::Embed.process!(input, client: client)
    #   response.embedding [0.0, ...]
    class Embed < OmniAI::Embed
      module Model
        SMALL = "text-embedding-3-small"
        LARGE = "text-embedding-3-large"
        ADA = "text-embedding-ada-002"
      end

      DEFAULT_MODEL = Model::LARGE

    protected

      # @return [Hash]
      def payload
        { model: @model, input: arrayify(@input) }
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/embeddings"
      end

      # @param [Object] value
      # @return [Array]
      def arrayify(value)
        value.is_a?(Array) ? value : [value]
      end
    end
  end
end

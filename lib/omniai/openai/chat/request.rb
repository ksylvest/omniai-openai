# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # An implementation of OmniAI::Chat::Request for OpenAI.
      class Request < OmniAI::Chat::Request
        protected

        # @return [Hash]
        def payload
          { messages: }.tap do |payload|
            payload[:model] = @model
            payload[:stream] = !@stream.nil? unless @stream.nil?
            payload[:temperature] = @temperature if @temperature
            payload[:response_format] = { type: 'json_object' } if @format.eql?(:json)
          end
        end

        # @return [Array<Hash>]
        def messages
          arrayify(@messages).map do |content|
            case content
            when String then { role: OmniAI::OpenAI::Chat::Role::USER, content: }
            when Hash then content
            else raise Error, "Unsupported content=#{content.inspect}"
            end
          end
        end

        # @return [String]
        def path
          "/#{OmniAI::OpenAI::Client::VERSION}/chat/completions"
        end

        private

        # @param value [Object, Array<Object>]
        # @return [Array<Object>]
        def arrayify(value)
          value.is_a?(Array) ? value : [value]
        end
      end
    end
  end
end

# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides tool-call message serialize / deserialize.
      module ToolCallMessageSerializer
        # @param message [OmniAI::Chat::ToolCallMessage]
        #
        # @return [Hash]
        def self.serialize(message, *)
          {
            type: "function_call_output",
            call_id: message.tool_call_id,
            output: JSON.generate(message.content),
          }
        end

        # @param data [Hash]
        #
        # @return [OmniAI::Chat::ToolCallMessage]
        def self.deserialize(data, *)
          content = data["content"]
          tool_call_id = data["call_id"]
          OmniAI::Chat::ToolCallMessage.new(content:, tool_call_id:)
        end
      end
    end
  end
end

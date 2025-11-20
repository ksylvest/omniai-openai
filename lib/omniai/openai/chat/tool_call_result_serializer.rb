# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides tool-call response serialize / deserialize.
      module ToolCallResultSerializer
        # @param tool_call_result [OmniAI::Chat::ToolCallResult]
        #
        # @return [Hash]
        def self.serialize(tool_call_result, *)
          {
            type: "function_call_output",
            call_id: tool_call_result.tool_call_id,
            output: tool_call_result.text,
          }
        end

        # @param data [Hash]
        #
        # @return [OmniAI::Chat::ToolCallResult]
        def self.deserialize(data, *)
          tool_call_id = data["call_id"]
          content = data["output"]

          OmniAI::Chat::ToolCallResult.new(content:, tool_call_id:)
        end
      end
    end
  end
end

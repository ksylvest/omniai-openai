# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides text serialize / deserialize.
      module ToolSerializer
        # @param tool [OmniAI::Tool]
        # @return [Hash]
        def self.serialize(tool, *)
          {
            type: "function",
            name: tool.name,
            description: tool.description,
            parameters: tool.parameters.is_a?(Schema::Object) ? tool.parameters.serialize : tool.parameters,
            strict: true,
          }
        end
      end
    end
  end
end

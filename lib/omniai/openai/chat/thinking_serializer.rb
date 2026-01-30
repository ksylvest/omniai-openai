# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides thinking serialize / deserialize.
      module ThinkingSerializer
        # @param data [Hash]
        # @param context [Context]
        #
        # @return [OmniAI::Chat::Thinking]
        def self.deserialize(data, context: nil) # rubocop:disable Lint/UnusedMethodArgument
          summary = data["summary"]

          thinking = case summary
                     when Array
                       summary.filter_map { |item| item["text"] if item["type"] == "summary_text" }.join("\n")
                     when String
                       summary
                     else
                       data["thinking"]
                     end

          OmniAI::Chat::Thinking.new(thinking)
        end

        # @param thinking [OmniAI::Chat::Thinking]
        # @param context [Context]
        #
        # @return [Hash]
        def self.serialize(thinking, context: nil) # rubocop:disable Lint/UnusedMethodArgument
          { type: "reasoning", summary: thinking.thinking }
        end
      end
    end
  end
end

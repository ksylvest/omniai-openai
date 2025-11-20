# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides text serialize / deserialize.
      module TextSerializer
        # @param text [OmniAI::Chat::Text]
        # @param direction [String] "input" or "output"
        #
        # @return [Hash]
        def self.serialize(text, direction:, **)
          raise text.inspect if direction.nil?

          { type: "#{direction}_text", text: text.text }
        end

        # @param data [Hash]
        #
        # @return [OmniAI::Chat::Text]
        def self.deserialize(data, *)
          OmniAI::Chat::Text.new(data["text"])
        end
      end
    end
  end
end

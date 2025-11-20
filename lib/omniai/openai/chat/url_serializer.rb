# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides media serialize / deserialize.
      module URLSerializer
        # @param url [OmniAI::Chat::URL]
        # @param direction [String] "input" or "output"
        #
        # @return [Hash]
        def self.serialize(url, direction:, **)
          type = url.image? ? "image" : "file"

          {
            type: "#{direction}_#{type}",
            "#{type}_url": url.uri,
          }
        end
      end
    end
  end
end

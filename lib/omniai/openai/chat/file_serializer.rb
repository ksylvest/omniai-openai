# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides file serialize / deserialize.
      module FileSerializer
        # @param file [OmniAI::Chat::File]
        # @param direction [String] "input" or "output"
        #
        # @return [Hash]
        def self.serialize(file, direction:, **)
          type = file.image? ? "image" : "file"

          {
            type: "#{direction}_#{type}",
            "#{type}_data": file.data,
            filename: file.filename,
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides response serialize / deserialize.
      module ResponseSerializer
        # @param response [OmniAI::Chat::Response]
        # @param context [OmniAI::Context]
        #
        # @return [Hash]
        def self.serialize(response, context:)
          usage = response.usage.serialize(context:)
          output = response.choices.serialize(context:)

          {
            usage:,
            output:,
          }
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Response]
        def self.deserialize(data, context:)
          usage = OmniAI::Chat::Usage.deserialize(data["usage"], context:) if data["usage"]
          choices = data["output"].map { |choice_data| OmniAI::Chat::Choice.deserialize(choice_data, context:) }

          OmniAI::Chat::Response.new(data:, choices:, usage:)
        end
      end
    end
  end
end

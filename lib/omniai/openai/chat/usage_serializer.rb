# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides usage deserialize to read OpenAI's reasoning breakdown.
      module UsageSerializer
        # OpenAI already counts reasoning inside `output_tokens` and reports the breakdown alongside it, so the
        # breakdown is read into `thinking_tokens` and the output count is left exactly as reported. Adding the two
        # together would double count.
        #
        # This gem targets the Responses API (`/responses`), whose usage object reports the breakdown at
        # `output_tokens_details.reasoning_tokens`. The Chat Completions vocabulary from the previous API
        # generation (`completion_tokens_details`) is deliberately not read — this gem never receives it.
        #
        # @param data [Hash]
        # @return [OmniAI::Chat::Usage]
        def self.deserialize(data, *)
          # Deserialize without a context so the generic flat parse runs rather than recursing into this method.
          usage = OmniAI::Chat::Usage.deserialize(data)

          # Only overwrite when the vendor container is actually present. A payload produced by `Usage#serialize`
          # carries base's own `thinking_tokens` key and no `output_tokens_details`, so assigning unconditionally
          # would clobber a correctly-parsed value with nil and break the round-trip. `unless nil?` rather than
          # `||=`, so a reported zero from the wire still wins over base's nil.
          reasoning_tokens = data.dig("output_tokens_details", "reasoning_tokens")
          usage.thinking_tokens = reasoning_tokens unless reasoning_tokens.nil?

          usage
        end
      end
    end
  end
end

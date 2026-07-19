# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides response serialize / deserialize.
      module ResponseSerializer
        # Maps OpenAI stop reasons onto the normalized OmniAI::Chat::FinishReason symbols. This gem uses the
        # Responses API, which exposes the reason via `incomplete_details.reason` / `status` (`completed`,
        # `max_output_tokens`, `content_filter`). The Chat-Completions tokens (`stop` / `length` / `tool_calls` /
        # `function_call`) cannot appear in a Responses-API status — they are included defensively for
        # OpenAI-compatible hosts that route Chat-Completions-shaped responses through this serializer. Unrecognized
        # values (`incomplete` without details, `failed`, ...) fall through to `:other`.
        FINISH_REASONS = {
          "completed" => OmniAI::Chat::FinishReason::STOP,
          "stop" => OmniAI::Chat::FinishReason::STOP,
          "max_output_tokens" => OmniAI::Chat::FinishReason::LENGTH,
          "length" => OmniAI::Chat::FinishReason::LENGTH,
          "tool_calls" => OmniAI::Chat::FinishReason::TOOL_CALL,
          "function_call" => OmniAI::Chat::FinishReason::TOOL_CALL,
          "content_filter" => OmniAI::Chat::FinishReason::FILTER,
        }.freeze
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
          choices = data["output"].filter_map { |choice_data| OmniAI::Chat::Choice.deserialize(choice_data, context:) }

          # The Responses API exposes the stop reason at the response level, not per output item: an explicit
          # `incomplete_details.reason` (e.g. "max_output_tokens" / "content_filter") when truncated, otherwise the
          # overall `status` (e.g. "completed" / "incomplete"). Normalize it to an OmniAI::Chat::FinishReason; the
          # verbatim token is preserved on the value object as `finish_reason.value`.
          raw_finish_reason = data.dig("incomplete_details", "reason") || data["status"]
          finish_reason = OmniAI::Chat::FinishReason.deserialize(raw_finish_reason, table: FINISH_REASONS)

          OmniAI::Chat::Response.new(data:, choices:, usage:, finish_reason:)
        end
      end
    end
  end
end

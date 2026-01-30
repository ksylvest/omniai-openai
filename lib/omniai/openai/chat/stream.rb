# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # For each chunk yield the text delta. Parse the final content into a response.
      class Stream < OmniAI::Chat::Stream
        # @yield [delta]
        # @yieldparam delta [OmniAI::Chat::Delta]
        #
        # @return [Hash]
        def stream!(&block)
          response = {}

          @chunks.each do |chunk|
            parser.feed(chunk.b) do |type, data, _id|
              case type
              when "response.output_text.delta"
                block.call(OmniAI::Chat::Delta.new(text: JSON.parse(data)["delta"]))
              when "response.reasoning_summary_text.delta"
                block.call(OmniAI::Chat::Delta.new(thinking: JSON.parse(data)["delta"]))
              when "response.completed"
                response = JSON.parse(data)["response"]
              end
            end
          end

          response
        end
      end
    end
  end
end

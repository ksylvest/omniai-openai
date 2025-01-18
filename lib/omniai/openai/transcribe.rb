# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI transcribe implementation.
    class Transcribe < OmniAI::Transcribe
      module Model
        WHISPER_1 = "whisper-1"
        WHISPER = WHISPER_1
      end

    protected

      # @return [Hash]
      def payload
        OmniAI::OpenAI
          .config.transcribe_options
          .merge(super)
          .merge({ response_format: @format || Format::JSON })
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/audio/transcriptions"
      end
    end
  end
end

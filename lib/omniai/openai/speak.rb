# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI transcribe implementation.
    class Speak < OmniAI::Speak
      module Model
        TTS_1 = 'tts-1'
        TTS_1_HD = 'tts-1-hd'
      end

      module Voice
        ALLOY = 'alloy' # https://platform.openai.com/docs/guides/text-to-speech/alloy
        ECHO = 'echo' # https://platform.openai.com/docs/guides/text-to-speech/echo
        FABLE = 'fable' # https://platform.openai.com/docs/guides/text-to-speech/fable
        NOVA = 'nova' # https://platform.openai.com/docs/guides/text-to-speech/nova
        ONYX = 'onyx' # https://platform.openai.com/docs/guides/text-to-speech/onyx
        SHIMMER = 'shimmer' # https://platform.openai.com/docs/guides/text-to-speech/shimmer
      end

      protected

      # @return [Hash]
      def payload
        OmniAI::OpenAI
          .config.speak_options
          .merge(super)
          .merge({ response_format: @format }.compact)
      end

      # @return [String]
      def path
        "/#{OmniAI::OpenAI::Client::VERSION}/audio/speech"
      end
    end
  end
end

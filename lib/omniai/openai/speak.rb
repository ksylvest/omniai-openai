# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI transcribe implementation.
    class Speak < OmniAI::Speak
      module Model
        TTS_1 = "tts-1"
        TTS_1_HD = "tts-1-hd"
        GPT_4O_MINI_TTS = "gpt-4o-mini-tts"
      end

      module Voice
        ALLOY = "alloy" # https://platform.openai.com/docs/guides/text-to-speech/alloy
        ASH = "ash" # https://platform.openai.com/docs/guides/text-to-speech/ash
        BALLAD = "ballad" # https://platform.openai.com/docs/guides/text-to-speech/ballad
        CEDAR = "cedar" # https://platform.openai.com/docs/guides/text-to-speech/cedar
        CORAL = "coral" # https://platform.openai.com/docs/guides/text-to-speech/coral
        ECHO = "echo" # https://platform.openai.com/docs/guides/text-to-speech/echo
        FABLE = "fable" # https://platform.openai.com/docs/guides/text-to-speech/fable
        MARIN = "marin" # https://platform.openai.com/docs/guides/text-to-speech/marin
        NOVA = "nova" # https://platform.openai.com/docs/guides/text-to-speech/nova
        ONYX = "onyx" # https://platform.openai.com/docs/guides/text-to-speech/onyx
        SAGE = "sage" # https://platform.openai.com/docs/guides/text-to-speech/sage
        SHIMMER = "shimmer" # https://platform.openai.com/docs/guides/text-to-speech/shimmer
        VERSE = "verse" # https://platform.openai.com/docs/guides/text-to-speech/verse
      end

      DEFAULT_MODEL = Model::GPT_4O_MINI_TTS
      DEFAULT_VOICE = Voice::ALLOY

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
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/audio/speech"
      end
    end
  end
end

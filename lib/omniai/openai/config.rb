# frozen_string_literal: true

module OmniAI
  module OpenAI
    # Configuration for managing the OpenAI `api_key` / `organization` / `project` / `logger`.
    class Config < OmniAI::Config
      attr_accessor :organization, :project, :chat_options, :transcribe_options, :speak_options

      DEFAULT_HOST = 'https://api.openai.com'

      def initialize
        super
        @api_key = ENV.fetch('OPENAI_API_KEY', nil)
        @organization = ENV.fetch('OPENAI_ORGANIZATION', nil)
        @project = ENV.fetch('OPENAI_PROJECT', nil)
        @host = ENV.fetch('OPENAI_HOST', DEFAULT_HOST)
        @chat_options = {}
        @transcribe_options = {}
        @speak_options = {}
      end
    end
  end
end

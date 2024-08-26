# frozen_string_literal: true

require 'event_stream_parser'
require 'omniai'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.push_dir(__dir__, namespace: OmniAI)
loader.inflector.inflect 'localai' => 'LocalAI'
loader.inflector.inflect 'openai' => 'OpenAI'
loader.inflector.inflect 'ollama' => 'Ollama'
loader.setup

module OmniAI
  # A namespace for everything OpenAI.
  module OpenAI
    # @return [OmniAI::OpenAI::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::OpenAI::Config]
    def self.configure
      yield config
    end
  end
end

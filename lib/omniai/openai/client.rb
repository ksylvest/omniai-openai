# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::OpenAI::Client.new(api_key: '...')
    #
    # w/ ENV['OPENAI_API_KEY']:
    #
    #   ENV['OPENAI_API_KEY'] = '...'
    #   client = OmniAI::OpenAI::Client.new
    #
    # w/ config:
    #
    #   OmniAI::OpenAI.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::OpenAI::Client.new
    class Client < OmniAI::Client
      VERSION = 'v1'

      # @param api_key [String, nil] optional - defaults to `OmniAI::OpenAI.config.api_key`
      # @param host [String] optional - defaults to `OmniAI::OpenAI.config.host`
      # @param project [String, nil] optional - defaults to `OmniAI::OpenAI.config.project`
      # @param organization [String, nil] optional - defaults to `OmniAI::OpenAI.config.organization`
      # @param logger [Logger, nil] optional - defaults to `OmniAI::OpenAI.config.logger`
      # @param timeout [Integer, nil] optional - defaults to `OmniAI::OpenAI.config.timeout`
      def initialize(
        api_key: OmniAI::OpenAI.config.api_key,
        host: OmniAI::OpenAI.config.host,
        organization: OmniAI::OpenAI.config.organization,
        project: OmniAI::OpenAI.config.project,
        logger: OmniAI::OpenAI.config.logger,
        timeout: OmniAI::OpenAI.config.timeout
      )
        if api_key.nil? && host.eql?(Config::DEFAULT_HOST)
          raise(
            ArgumentError,
            %(ENV['OPENAI_API_KEY'] must be defined or `api_key` must be passed when using #{Config::DEFAULT_HOST})
          )
        end

        super(api_key:, host:, logger:, timeout:)

        @organization = organization
        @project = project
      end

      # @return [HTTP::Client]
      def connection
        @connection ||= begin
          http = super
          http = http.auth("Bearer #{@api_key}") if @api_key
          http = http.headers('OpenAI-Organization': @organization) if @organization
          http = http.headers('OpenAI-Project': @project) if @project
          http
        end
      end

      # @raise [OmniAI::Error]
      #
      # @param messages [String, Array, Hash]
      # @param model [String] optional
      # @param format [Symbol] optional :text or :json
      # @param temperature [Float, nil] optional
      # @param stream [Proc, nil] optional
      # @param tools [Array<OmniAI::Tool>, nil] optional
      #
      # @return [OmniAI::Chat::Completion]
      def chat(messages, model: Chat::DEFAULT_MODEL, temperature: nil, format: nil, stream: nil, tools: nil)
        Chat.process!(messages, model:, temperature:, format:, stream:, tools:, client: self)
      end

      # @raise [OmniAI::Error]
      #
      # @param path [String]
      # @param model [String]
      # @param language [String, nil] optional
      # @param prompt [String, nil] optional
      # @param temperature [Float, nil] optional
      # @param format [Symbol] :text, :srt, :vtt, or :json (default)
      #
      # @return [OmniAI::Transcribe]
      def transcribe(path, model: Transcribe::Model::WHISPER, language: nil, prompt: nil, temperature: nil, format: nil)
        Transcribe.process!(path, model:, language:, prompt:, temperature:, format:, client: self)
      end

      # @raise [OmniAI::Error]
      #
      # @param input [String] required
      # @param model [String] optional
      # @param voice [String] optional
      # @param speed [Float] optional
      # @param format [String] optional (default "aac"):
      #   - "aac"
      #   - "mp3"
      #   - "flac"
      #   - "opus"
      #   - "pcm"
      #   - "wav"
      #
      # @yield [output] optional
      #
      # @return [Tempfile``]
      def speak(input, model: Speak::Model::TTS_1_HD, voice: Speak::Voice::ALLOY, speed: nil, format: nil, &)
        Speak.process!(input, model:, voice:, speed:, format:, client: self, &)
      end

      # @return [OmniAI::OpenAI::Files]
      def files
        Files.new(client: self)
      end

      # @return [OmniAI::OpenAI::Assistants]
      def assistants
        Assistants.new(client: self)
      end

      # @return [OmniAI::OpenAI::Threads]
      def threads
        Threads.new(client: self)
      end
    end
  end
end

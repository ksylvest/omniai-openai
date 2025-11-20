# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI chat implementation.
    #
    # Usage:
    #
    #   completion = OmniAI::OpenAI::Chat.process!(client: client) do |prompt|
    #     prompt.system('You are an expert in the field of AI.')
    #     prompt.user('What are the biggest risks of AI?')
    #   end
    #   completion.choice.message.content # '...'
    class Chat < OmniAI::Chat
      DEFAULT_STREAM_OPTIONS = { include_usage: ENV.fetch("OMNIAI_STREAM_USAGE", "on").eql?("on") }.freeze

      module ResponseFormat
        TEXT_TYPE = "text"
        JSON_TYPE = "json_object"
        SCHEMA_TYPE = "json_schema"
      end

      module ReasoningEffort
        NONE = "none"
        LOW = "low"
        MEDIUM = "medium"
        HIGH = "high"
      end

      module VerbosityText
        LOW = "low"
        MEDIUM = "medium"
        HIGH = "high"
      end

      module Model
        GPT_5_1 = "gpt-5.1"
        GPT_5 = "gpt-5"
        GPT_5_MINI = "gpt-5-mini"
        GPT_5_NANO = "gpt-5-nano"
        GPT_4_1 = "gpt-4.1"
        GPT_4_1_NANO = "gpt-4.1-nano"
        GPT_4_1_MINI = "gpt-4.1-mini"
        GPT_4O = "gpt-4o"
        GPT_4O_MINI = "gpt-4o-mini"
        GPT_4 = "gpt-4"
        GPT_4_TURBO = "gpt-4-turbo"
        GPT_3_5_TURBO = "gpt-3.5-turbo"
        O1_MINI = "o1-mini"
        O3_MINI = "o3-mini"
        O4_MINI = "o4-mini"
        O1 = "o1"
        O3 = "o3"
      end

      DEFAULT_MODEL = Model::GPT_4_1

    protected

      # @return [Float, nil]
      def temperature
        return if @temperature.nil?

        return if [
          Model::GPT_5,
          Model::GPT_5_MINI,
          Model::GPT_5_NANO,
          Model::GPT_5_1,
          Model::O1_MINI,
          Model::O1,
          Model::O3_MINI,
        ].include?(@model)

        @temperature
      end

      # @return [Hash]
      def payload
        OmniAI::OpenAI.config.chat_options.merge({
          messages: @prompt.serialize,
          model: @model,
          response_format:,
          stream: stream? || nil,
          stream_options: (DEFAULT_STREAM_OPTIONS if stream?),
          temperature:,
          tools: (@tools.map(&:serialize) if @tools&.any?),
          reasoning_effort: reasoning_effort_payload,
          verbosity: verbosity_payload,
        }.merge(@kwargs || {})).compact
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/chat/completions"
      end

      # @raise [ArgumentError]
      #
      # @return [Hash, nil]
      def response_format
        return if @format.nil?

        case @format
        when :text then { type: ResponseFormat::TEXT_TYPE }
        when :json then { type: ResponseFormat::JSON_TYPE }
        when OmniAI::Schema::Format then { type: ResponseFormat::SCHEMA_TYPE, json_schema: @format.serialize }
        else raise ArgumentError, "unknown format=#{@format}"
        end
      end

      # @raise [ArgumentError]
      #
      # @return [String, nil]
      def reasoning_effort_payload
        return if @reasoning.nil?

        effort = @reasoning[:effort] || @reasoning["effort"]
        return if effort.nil?

        valid_efforts = [ReasoningEffort::NONE, ReasoningEffort::LOW, ReasoningEffort::MEDIUM, ReasoningEffort::HIGH]
        unless valid_efforts.include?(effort)
          raise ArgumentError,
            "reasoning effort must be one of #{valid_efforts.join(', ')}"
        end

        effort
      end

      # @raise [ArgumentError]
      #
      # @return [String, nil]
      def verbosity_payload
        return if @verbosity.nil?

        text = @verbosity[:text] || @verbosity["text"]
        return if text.nil?

        valid_text_levels = [VerbosityText::LOW, VerbosityText::MEDIUM, VerbosityText::HIGH]
        unless valid_text_levels.include?(text)
          raise ArgumentError,
            "verbosity text must be one of #{valid_text_levels.join(', ')}"
        end

        text
      end
    end
  end
end

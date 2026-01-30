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
        GPT_5_2 = "gpt-5.2"
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

      DEFAULT_MODEL = Model::GPT_5_2

      # @return [Context]
      CONTEXT = Context.build do |context|
        context.serializers[:choice] = ChoiceSerializer.method(:serialize)
        context.deserializers[:choice] = ChoiceSerializer.method(:deserialize)
        context.serializers[:message] = MessageSerializer.method(:serialize)
        context.deserializers[:message] = MessageSerializer.method(:deserialize)
        context.serializers[:text] = TextSerializer.method(:serialize)
        context.deserializers[:text] = TextSerializer.method(:deserialize)
        context.serializers[:response] = ResponseSerializer.method(:serialize)
        context.deserializers[:response] = ResponseSerializer.method(:deserialize)
        context.deserializers[:content] = ContentSerializer.method(:deserialize)
        context.serializers[:file] = FileSerializer.method(:serialize)
        context.serializers[:url] = URLSerializer.method(:serialize)
        context.serializers[:tool] = ToolSerializer.method(:serialize)
        context.serializers[:tool_call] = ToolCallSerializer.method(:serialize)
        context.deserializers[:tool_call] = ToolCallSerializer.method(:deserialize)
        context.serializers[:tool_call_result] = ToolCallResultSerializer.method(:serialize)
        context.deserializers[:tool_call_result] = ToolCallResultSerializer.method(:deserialize)
        context.serializers[:tool_call_message] = ToolCallMessageSerializer.method(:serialize)
        context.deserializers[:tool_call_message] = ToolCallMessageSerializer.method(:deserialize)
        context.serializers[:thinking] = ThinkingSerializer.method(:serialize)
        context.deserializers[:thinking] = ThinkingSerializer.method(:deserialize)
      end

    protected

      # @return [Context]
      def context
        CONTEXT
      end

      # @return [Array<Hash>]
      def input
        @prompt
          .messages
          .reject(&:system?)
          .filter_map { |message| message.serialize(context:) }
      end

      # @return [String, nil]
      def instructions
        parts = @prompt
          .messages
          .filter(&:system?)
          .filter(&:text?)
          .map(&:text)

        return if parts.empty?

        parts.join("\n\n")
      end

      # @return [Float, nil]
      def temperature
        return if @temperature.nil?

        return if [
          Model::GPT_5,
          Model::GPT_5_MINI,
          Model::GPT_5_NANO,
          Model::GPT_5_1,
          Model::GPT_5_2,
          Model::O1_MINI,
          Model::O1,
          Model::O3_MINI,
        ].include?(@model)

        @temperature
      end

      # @return [Hash]
      def payload
        OmniAI::OpenAI.config.chat_options.merge({
          instructions:,
          input:,
          model: @model || DEFAULT_MODEL,
          stream: stream? || nil,
          temperature:,
          tools:,
          text:,
          reasoning:,
        }).compact
      end

      # @return [Array<Hash>]
      def tools
        return unless @tools&.any?

        @tools.map { |tool| tool.serialize(context:) }
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/responses"
      end

      # @return [Hash]
      def text
        options = @options.fetch(:text, {}).merge(format:).compact
        options unless options.empty?
      end

      # @return [Hash]
      # Accepts unified `thinking:` option and translates to OpenAI's `reasoning:` format.
      # Example: `thinking: { effort: "high" }` becomes `reasoning: { effort: "high", summary: "auto" }`
      def reasoning
        # Support both native `reasoning:` and unified `thinking:` options
        options = @options[:reasoning] || translate_thinking_to_reasoning
        options unless options.nil? || options.empty?
      end

      # Translates unified thinking option to OpenAI reasoning format
      # @return [Hash, nil]
      def translate_thinking_to_reasoning
        thinking = @options[:thinking]
        return unless thinking

        case thinking
        when true then { effort: ReasoningEffort::HIGH, summary: "auto" }
        when Hash then { summary: "auto" }.merge(thinking)
        end
      end

      # @raise [ArgumentError]
      #
      # @return [Hash, nil]
      def format
        return if @format.nil?

        case @format
        when :text then { type: ResponseFormat::TEXT_TYPE }
        when :json then { type: ResponseFormat::JSON_TYPE }
        when OmniAI::Schema::Format
          @format.serialize.merge({ type: ResponseFormat::SCHEMA_TYPE, strict: true })
        else raise ArgumentError, "unknown format=#{@format}"
        end
      end

      # @return [Array<ToolCallMessage>]
      def build_tool_call_messages(tool_call_list)
        tool_call_list.map do |tool_call|
          ToolCallMessage.new(tool_call_id: tool_call.id, content: execute_tool_call(tool_call))
        end
      end
    end
  end
end

# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Chat
      # Overrides message serialize / deserialize.
      module MessageSerializer
        # @param message [OmniAI::Chat::Message]
        # @param context [OmniAI::Context]
        #
        # @return [Hash]
        def self.serialize(message, context:)
          if message.tool?
            serialize_for_tool_call(message, context:)
          else
            serialize_for_content(message, context:)
          end
        end

        # @param message [OmniAI::Chat::Message]
        # @param context [OmniAI::Context]
        #
        # @return [Hash]
        def self.serialize_for_tool_call(message, context:)
          tool_call_list = message.tool_call_list
          tool_call = tool_call_list[0]
          tool_call.serialize(context:)
        end

        # @param message [OmniAI::Chat::Message]
        # @param context [OmniAI::Context]
        #
        # @return [Hash]
        def self.serialize_for_content(message, context:)
          role = message.role
          direction = message.direction
          parts = arrayify(message.content)

          content = parts.map do |part|
            case part
            when String then { type: "#{direction}_text", text: part }
            else part.serialize(context:, direction:)
            end
          end

          { role:, content: }
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Message]
        def self.deserialize(data, context:)
          case data["type"]
          when "message" then deserialize_for_content(data, context:)
          when "function_call" then deserialize_for_tool_call(data, context:)
          end
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Message]
        def self.deserialize_for_content(data, context:)
          role = data["role"]
          content = data["content"].map do |content|
            OmniAI::Chat::Content.deserialize(content, context:)
          end
          OmniAI::Chat::Message.new(role:, content:)
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Message]
        def self.deserialize_for_tool_call(data, context:)
          entry = OmniAI::Chat::ToolCall.deserialize(data, context:)
          tool_call_list = OmniAI::Chat::ToolCallList.new(entries: [entry])
          OmniAI::Chat::Message.new(role: OmniAI::Chat::Role::TOOL, content: nil, tool_call_list:)
        end

        # @param content [Object]
        #
        # @return [Array<Object>]
        def self.arrayify(content)
          return [] if content.nil?

          content.is_a?(Array) ? content : [content]
        end
      end
    end
  end
end

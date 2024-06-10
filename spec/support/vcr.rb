# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :webmock

  config.define_cassette_placeholder('<OPENAI_API_KEY>') { OmniAI::OpenAI.config.api_key }
end

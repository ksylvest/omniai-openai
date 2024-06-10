# frozen_string_literal: true

require 'omniai/openai'

require_relative 'support/vcr'
require_relative 'support/webmock'

OmniAI::OpenAI.configure do |config|
  config.api_key = '...'
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

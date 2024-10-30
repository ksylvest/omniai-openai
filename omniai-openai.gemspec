# frozen_string_literal: true

require_relative 'lib/omniai/openai/version'

Gem::Specification.new do |spec|
  spec.name = 'omniai-openai'
  spec.version = OmniAI::OpenAI::VERSION
  spec.license = 'MIT'
  spec.authors = ['Kevin Sylvestre']
  spec.email = ['kevin@ksylvest.com']

  spec.summary = 'A generalized framework for interacting with OpenAI'
  spec.description = 'An implementation of OmniAI for OpenAI'
  spec.homepage = 'https://github.com/ksylvest/omniai-openai'

  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{lib}/**/*') + %w[README.md Gemfile]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'event_stream_parser'
  spec.add_dependency 'omniai'
  spec.add_dependency 'zeitwerk'
end

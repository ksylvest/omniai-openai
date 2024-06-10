# frozen_string_literal: true

require_relative "lib/omniai/openai/version"

Gem::Specification.new do |spec|
  spec.name = "omniai-openai"
  spec.version = OmniAI::OpenAI::VERSION
  spec.authors = ["Kevin Sylvestre"]
  spec.email = ["kevin@ksylvest.com"]

  spec.summary = "A generalized framework for interacting with OpenAI"
  spec.description = "An implementation of OmniAI for OpenAI"
  spec.homepage = "https://github.com/ksylvest/omniai-openai"
  spec.required_ruby_version = ">= 3.0.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "omniai"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
end

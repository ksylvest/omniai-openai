# Changelog

## 3.2.0

### Added

- `OmniAI::Chat::Usage#thinking_tokens` is now populated from the Responses API `usage` object, read from `output_tokens_details.reasoning_tokens`. Reasoning spend was previously unreadable through this gem — callers had to reach into `response.data`. Requires omniai >= 3.8.

  OpenAI already counts reasoning inside `output_tokens`, so this reports the breakdown without changing the output total. `thinking_tokens` is a subset, not an addition — adding it to `output_tokens` double counts.

  Note the vocabulary: this gem targets the Responses API (`/responses`), whose usage object nests the breakdown under `output_tokens_details`. The `completion_tokens_details` key belongs to Chat Completions, the previous API generation, and is deliberately not read — this gem never receives it.

- Specs for usage deserialization, which this suite previously had none of.

Earlier changes are recorded in the GitHub releases.

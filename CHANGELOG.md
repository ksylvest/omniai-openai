# Changelog

## 3.2.0

### Added

- `OmniAI::Chat::Usage#thinking_tokens` is now populated from the Responses API `usage` object, read from `output_tokens_details.reasoning_tokens`. Reasoning spend was previously unreadable through this gem — callers had to reach into `response.data`. Requires omniai >= 3.8.

  OpenAI already counts reasoning inside `output_tokens`, so this reports the breakdown without changing the output total. `thinking_tokens` is a subset, not an addition — adding it to `output_tokens` double counts.

  Note the vocabulary: this gem targets the Responses API (`/responses`), whose usage object nests the breakdown under `output_tokens_details`. The `completion_tokens_details` key belongs to Chat Completions, the previous API generation, and is deliberately not read — this gem never receives it.

- Specs for usage deserialization, which this suite previously had none of. Fixtures are captured from a live `/v1/responses` call and carry provenance comments naming model, endpoint and date.

### Changed

- The `omniai` dependency floor moves from `~> 3.0` to `~> 3.8`. If you are on omniai 3.0–3.7 this is a forced upgrade, and it is the largest one in this release train: `Usage#thinking_tokens` does not exist before 3.8, so without the bump this gem would install cleanly and the new field would silently read `nil` rather than the reasoning count. The old floor was also simply stale — it predates several releases this gem already depended on in practice.

Earlier changes are recorded in the GitHub releases.

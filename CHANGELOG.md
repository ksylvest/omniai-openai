# Changelog

## 3.3.0

### Added

- GPT-6 model constants: `GPT_6_1_SOL`, `GPT_6_ASTRA`, `GPT_6_SOL`, `GPT_6_LUNA`. They are not in `TEMPERATURE_UNSUPPORTED_MODELS`; that needs a live check.
- `ReasoningEffort::MINIMAL`, `XHIGH` and `MAX`. Support varies by model: GPT-6 models don't accept `minimal`, and `gpt-6-astra` and `gpt-6.1-sol` also reject `none`.

### Deprecated

Dates are from OpenAI's [deprecations page](https://developers.openai.com/api/docs/deprecations). The constants still resolve; they will be removed in a later release.

- Already shut down (2025-10-27): `O1_MINI`
- 2026-10-23: `GPT_4`, `GPT_4_TURBO`, `GPT_3_5_TURBO`, `GPT_4_1_NANO`, `O1`, `O3_MINI`, `O4_MINI`
- 2026-12-11, the dated snapshot behind each alias: `O3`, `GPT_5`, `GPT_5_MINI`, `GPT_5_NANO`, `GPT_5_PRO`
- 2027-01-06: `Speak::Model::TTS_1`, `TTS_1_HD`, and both `gpt-4o-mini-tts` snapshots. That is `Speak::DEFAULT_MODEL`, so the default speech model may stop working that day.
- 2027-02-26: `Transcribe::Model::WHISPER_1` / `WHISPER` (the current `Transcribe::DEFAULT_MODEL`), `GPT_4O_TRANSCRIBE`, `GPT_4O_MINI_TRANSCRIBE`, `GPT_4O_TRANSCRIBE_DIARIZE`
- 2027-04-01: `GPT_5_1`, `GPT_5_3_CODEX`, `GPT_5_4_NANO`

Changing either default is a behaviour change, so it belongs in its own release before those dates.

### Fixed

- README: reasoning examples used `o3-mini`, and the Speak model example passed a model as `format:`.

## 3.2.0

### Added

- `OmniAI::Chat::Usage#thinking_tokens` is now populated from the Responses API `usage` object, read from `output_tokens_details.reasoning_tokens`. Reasoning spend was previously unreadable through this gem — callers had to reach into `response.data`. Requires omniai >= 3.8.

  OpenAI already counts reasoning inside `output_tokens`, so this reports the breakdown without changing the output total. `thinking_tokens` is a subset, not an addition — adding it to `output_tokens` double counts.

  Note the vocabulary: this gem targets the Responses API (`/responses`), whose usage object nests the breakdown under `output_tokens_details`. The `completion_tokens_details` key belongs to Chat Completions, the previous API generation, and is deliberately not read — this gem never receives it.

- Specs for usage deserialization, which this suite previously had none of. Fixtures are captured from a live `/v1/responses` call and carry provenance comments naming model, endpoint and date.

### Changed

- The `omniai` dependency floor moves from `~> 3.0` to `~> 3.8`. If you are on omniai 3.0–3.7 this is a forced upgrade, and it is the largest one in this release train: `Usage#thinking_tokens` does not exist before 3.8, so without the bump this gem would install cleanly and the new field would silently read `nil` rather than the reasoning count. The old floor was also simply stale — it predates several releases this gem already depended on in practice.

Earlier changes are recorded in the GitHub releases.

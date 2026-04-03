# Security Architecture Model Benchmark

## Status

This document records the local-model evaluation for the `Security Architecture` Telegram topic in the current OpenClaw deployment.

The goal is not generic model benchmarking. The goal is to choose the best realistic **local Ollama model** for architecture discussion about the actual deployed OpenClaw system.

This is a working benchmark note. It reflects completed test runs as of `2026-03-29`.

Companion evidence file:

- [security-architecture-model-benchmark-artifacts.md](./security-architecture-model-benchmark-artifacts.md)

## Objective

Pick the strongest local model for the `security-architecture` topic under these constraints:

- no external API key
- discussion quality matters more than speed
- maximum tolerated response time is under 5 minutes
- the model must work with the live `security-architecture` workspace prompt
- the model must reason about the current OpenClaw architecture, not collapse into generic sysadmin advice

## Environment

- Host Ollama endpoint used by the deployment:
  - `http://host.docker.internal:11434`
- Runtime invoking the benchmark:
  - `upstream-openclaw-openclaw-gateway-1`
- Security Architecture workspace prompt:
  - `/home/node/.openclaw/workspace-security-architecture/AGENTS.md`
  - `/home/node/.openclaw/workspace-security-architecture/skills/security-architecture/SKILL.md`

Relevant host capability context:

- GPU: RTX 4060 with approximately 8 GB VRAM
- System RAM: approximately 23 GiB usable

## Candidate Set

### Initially installed

- `llama3.1:8b`
- `qwen2.5:7b`
- `qwen3:4b`
- `qwen3:8b`
- `qwen3:14b`
- `codegemma:7b`
- `qwen2.5-coder:7b`
- `gemma3:4b`

### Pulled specifically for this evaluation

- `mistral-nemo:latest`
- `gemma3:12b`
- `mistral-small` is still in progress and is not included in the completed results below

## Prompt Basis

The benchmark used the live `security-architecture` system prompt, not a synthetic benchmark prompt.

The core behavior enforced by that prompt is:

- discussion-first architecture review
- no default drift into generic shell checks or sudo
- explicit separation of:
  - judgment
  - evidence used
  - assumptions
  - unknowns
  - preferred path

## Benchmark Questions

Completed tuned benchmark used these user prompts:

1. `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`
2. `What is the weakest trust boundary in my current setup?`

Earlier baseline work also included:

3. `Which parts of this architecture are acceptable interim design versus wrong long-term design?`

## Methodology

### Baseline pass

The first pass called the Ollama chat API directly using:

- low temperature
- moderate output cap
- same system prompt for all models

This surfaced an important issue:

- `qwen3:8b` and `qwen3:14b` initially appeared to return empty output
- that was a **bad benchmark conclusion**
- the actual raw API responses showed the models were writing into the `message.thinking` field and exhausting the token budget before producing final `content`

### Corrected tuning pass

The corrected pass used:

- `temperature: 0.15`
- `num_predict: 400`
- `think: false` for `qwen3:8b` and `qwen3:14b`

This was necessary because Qwen 3 supports a `think` field in Ollama chat responses. Without turning thinking off, the benchmark was unfair.

### What was measured

For each prompt and model:

- end-to-end latency in milliseconds
- response content
- whether the answer was empty
- whether it hit `done_reason: "length"`
- qualitative fit for the `Security Architecture` role

### What was judged qualitatively

Models were not ranked on style alone. They were judged on:

- ability to make a clear architectural judgment
- ability to reason from known system context instead of punting immediately
- tendency to invent facts or overclaim
- tendency to collapse into generic checklists
- tendency to confuse OpenClaw architecture review with generic Docker/Linux hardening
- latency relative to the value of the answer

## Completed Tuned Results

### `llama3.1:8b`

Latency:

- `18120 ms` on prompt 1
- `16280 ms` on prompt 2

Observed behavior:

- reliable output
- relatively fast
- still too context-hungry
- often says there is not enough evidence and asks for more detail
- less aggressive than Qwen 3, but also less decisive

Assessment:

- safe and usable
- not strong enough to be the final winner yet
- current best balance among the clearly stable models

### `qwen2.5:7b`

Latency:

- `13647 ms` on prompt 1
- `7666 ms` on prompt 2

Observed behavior:

- reliable output
- too generic
- checklist-heavy
- drifts into broad architecture boilerplate
- tends to answer like a generic assistant rather than a sharp reviewer

Assessment:

- stable but weak
- no longer a leading candidate

### `qwen3:8b` with `think: false`

Latency:

- `15823 ms` on prompt 1
- `8545 ms` on prompt 2

Observed behavior:

- reliable output after tuning
- makes a clear judgment quickly
- discussion shape is closer to what the topic wants
- still overconfident in places
- still invents some facts not actually verified in context
- still tends to state architecture weaknesses too concretely without enough grounding

Assessment:

- strong candidate
- materially better than the earlier broken baseline suggested
- currently the most serious challenger to `llama3.1:8b`

### `qwen3:14b` with `think: false`

Latency:

- `115055 ms` on prompt 1
- `106867 ms` on prompt 2

Observed behavior:

- reliable output after tuning
- same general answer shape as `qwen3:8b`
- somewhat more composed than `qwen3:8b`
- still overassertive about boundaries and controls that were not directly verified
- much slower

Assessment:

- technically within the 5-minute ceiling
- quality gain over `qwen3:8b` is not obviously large enough yet to justify the extra latency
- still a viable candidate, but currently not the leading practical choice

### `mistral-nemo:latest`

Latency:

- `50216 ms` on prompt 1
- `44195 ms` on prompt 2

Observed behavior:

- reliable output
- repeatedly asks for more setup details instead of making a strong judgment from known context
- on the second prompt it drifted into generic Docker-container trust-boundary advice
- felt more like a general infrastructure assistant than a purpose-built architecture reviewer

Assessment:

- not competitive at the moment
- too generic for this topic despite acceptable latency

### `gemma3:12b`

Latency:

- `75199 ms` on prompt 1
- `73915 ms` on prompt 2

Observed behavior:

- reliable output
- structurally follows the requested answer discipline better than some others
- still hedges heavily
- still generic
- does not show enough architecture-specific sharpness to justify the slower runtime

Assessment:

- usable
- not a winning candidate so far

### `mistral-small:latest`

Latency:

- `204660 ms` on prompt 1
- `213125 ms` on prompt 2

Observed behavior:

- reliable output
- stronger than `mistral-nemo` in answer completeness
- still generic
- still leans on broad infrastructure-security defaults
- too slow relative to the quality gain

Assessment:

- technically within the 5-minute ceiling
- not competitive enough to justify the latency

## Important Correction: Qwen 3 Was Mis-scored Initially

The earlier benchmark conclusion that `qwen3:8b` and `qwen3:14b` were unusable was wrong.

Actual issue:

- Qwen 3 was spending tokens in Ollama's `thinking` field
- benchmark code only checked `message.content`
- the models then hit `done_reason: "length"` before emitting final answer text

Correct fix:

- set `think: false`

This is a legitimate documented Ollama parameter, not a workaround.

## Interim Ranking

Based on the completed tuned pass:

1. `qwen3:8b`
2. `llama3.1:8b`
3. `qwen3:14b`
4. `mistral-small:latest`
5. `gemma3:12b`
6. `mistral-nemo:latest`
7. `qwen2.5:7b`

This ranking is provisional because:

- `mistral-small` is still being pulled
- a shared-context comparison pass is still useful for the context-hungry models

## Interpretation

### What currently looks best

`qwen3:8b` is the strongest current candidate if the requirement is:

- sharper discussion than `llama3.1:8b`
- acceptable latency
- local-only deployment

### What currently looks safest

`llama3.1:8b` is still the safest conservative choice if the requirement is:

- predictable behavior
- faster stable output
- fewer hard overclaims

### What does not currently look worth it

- `mistral-nemo:latest`
- `gemma3:12b`
- `mistral-small:latest`

These both run, but neither currently justifies the slower response time with better architecture-review quality.

## Shared-Context Finalist Check

A short shared-context comparison was run for the two realistic finalists:

- `llama3.1:8b`
- `qwen3:8b` with `think: false`

Shared context block included:

- host machine
- WSL
- Docker gateway
- Telegram topics
- host bridge
- deterministic Host Control
- discussion-first Security Architecture
- recurring trust-boundary confusion between host, container, Telegram, plugins, and bridge

### Result

`llama3.1:8b`

- `20385 ms`
- improved over the zero-context case
- still cautious and somewhat hedged
- still stops short of a firm conclusion

`qwen3:8b`

- `16257 ms`
- produced the sharper architecture judgment
- still somewhat overassertive
- but remained the stronger reviewer in the same context window

Interpretation:

- extra context helps both models
- `llama3.1:8b` becomes more usable
- `qwen3:8b` still wins on architectural decisiveness and discussion quality

## Detailed Failure Analysis

This section records **why** specific outputs were judged weak. The issue is not only whether a model answered, but whether it answered in the right architectural mode for this topic.

### `llama3.1:8b`

Main failure mode:

- too context-hungry
- too willing to defer judgment

Evidence from output:

- on prompt 1, it said there was not enough information and recommended documenting the design instead of making a strong provisional judgment
- on prompt 2, it answered with a broad trust-boundary checklist and again asked for more setup detail

Why that is a problem here:

- the `Security Architecture` topic already has system-level context in the workspace prompt
- this model is under-using known context
- it is safer than some others, but it behaves more like a cautious reviewer with incomplete notes than a strong architecture critic

Net effect:

- acceptable fallback
- not the strongest discussion model

### `qwen2.5:7b`

Main failure mode:

- generic checklist drift
- not specific enough to the actual OpenClaw deployment

Evidence from output:

- it framed the answer as a broad set of categories such as host vs container, authentication, external integrations, and data flow
- it repeatedly asked for more setup detail in the middle of the answer
- it sounded like a standard architecture questionnaire rather than an architectural judgment

Why that is a problem here:

- the user wants critique of the current OpenClaw design, not a generic consultation template
- the model does not sufficiently exploit the known recurring issue: trust-boundary confusion between host, WSL, Docker, Telegram, plugins, and bridge

Net effect:

- stable but too generic to justify selection

### `qwen3:8b`

Main failure mode:

- overconfident inference
- asserts controls or weaknesses too concretely without enough verified support

Evidence from output:

- on prompt 1, it claimed the architecture had “significant trust boundary risks” and described missing least-privilege and hardening controls as if they were established facts
- on prompt 2, it identified the weakest boundary as the bridge between the runtime and Telegram and recommended mutual TLS, even though that specific control gap was not established in the known context

Why that is a problem here:

- this topic must separate verified fact from inference
- the model’s answer shape is strong, but it tends to convert plausible inference into authoritative-sounding fact

Why it is still a leading candidate:

- despite that flaw, it gives the strongest discussion-first answer shape among the tested models
- it is much closer to the intended reviewer posture than the more generic alternatives

Net effect:

- best current candidate, but only with clear caveats

### `qwen3:14b`

Main failure mode:

- same overconfidence pattern as `qwen3:8b`
- much slower

Evidence from output:

- on prompt 1, it said the architecture was workaround-laden and described absent boundary separation and hardening as if those were already verified
- on prompt 2, it declared the Telegram integration to be the weakest trust boundary and asserted lack of input validation and sanitization without that being directly established in the prompt context

Why that is a problem here:

- it shares the same factual-discipline weakness as `qwen3:8b`
- the extra latency only makes sense if it also shows materially better judgment quality
- so far that improvement is not clear

Net effect:

- viable, but currently not worth the latency premium

### `mistral-nemo:latest`

Main failure mode:

- context-seeking instead of judging
- wrong abstraction level on follow-up

Evidence from output:

- on prompt 1, it mostly asked for setup details instead of giving a strong provisional judgment from known context
- on prompt 2, it defaulted to the host-vs-container boundary and generic Docker daemon risk language

Why that is a problem here:

- this topic is supposed to review the OpenClaw architecture as deployed, not collapse into generic container-security advice
- the model behaves like it needs a fresh discovery interview before it can say anything useful

Net effect:

- not competitive for this use case

### `gemma3:12b`

Main failure mode:

- well-structured but still generic
- too hedged for the latency cost

Evidence from output:

- on prompt 1, it followed the requested answer structure, but the substance remained broad and provisional
- on prompt 2, it declared the plugin surface as the weakest trust boundary based largely on generic plugin-risk assumptions rather than known OpenClaw specifics

Why that is a problem here:

- structure alone is not enough
- the model sounds disciplined, but it is still filling gaps with generic architecture heuristics instead of engaging tightly with the actual deployment shape

Net effect:

- competent but not compelling

## Why These Failures Matter

For this topic, a “good” answer is not just fluent. It needs to satisfy all of these at once:

- make a real architectural judgment
- use known context instead of demanding a full rediscovery every time
- separate verified fact from inference
- avoid generic enterprise-security boilerplate
- stay within acceptable latency

The models that were downgraded failed one or more of those conditions in consistent ways.

## Known Limitations of This Benchmark

- This is a direct Ollama chat benchmark, not a live Telegram topic benchmark.
- The benchmark relies on the current `security-architecture` prompt quality; if that prompt improves, the winner may shift.
- Only two tuned prompts were used in the completed final pass.
- Shared-context evaluation is not finished yet.
- `mistral-small` is still pending and may change the ranking if it performs unexpectedly well.

## Next Steps

1. Decide whether the production choice should optimize for:
   - strongest judgment quality
   - or safest conservative behavior
2. Switch the live `security-architecture` topic model.
3. Keep the benchmark docs in repo so future model changes are compared against a real baseline.

## Recommendation if a Decision Had to Be Made Right Now

Final recommendation from completed results:

- choose `qwen3:8b` with `think: false`

Reason:

- it currently gives the strongest architecture-review shape at acceptable latency
- it is materially better than the original broken benchmark suggested
- it remains stronger than `llama3.1:8b` even after the shared-context comparison
- it is much more practical than `qwen3:14b`
- the slower Mistral and Gemma candidates did not justify their latency cost

Operational caveat:

- use `think: false` for Qwen 3 in Ollama chat calls
- otherwise the model may spend its token budget in the `thinking` channel instead of returning usable answer text

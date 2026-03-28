# Security Architecture Model Benchmark Artifacts

## Purpose

This file stores concrete artifacts behind the model benchmark judgments in:

- [security-architecture-model-benchmark.md](/home/mfshaf7/projects/openclaw-isolated-deployment/docs/security-architecture-model-benchmark.md)

It is intentionally selective:

- enough raw evidence to justify the ranking
- not a full dump of every token from every run

## System Prompt Basis

All benchmark excerpts below used the live `Security Architecture` workspace prompt:

- `/home/node/.openclaw/workspace-security-architecture/AGENTS.md`
- `/home/node/.openclaw/workspace-security-architecture/skills/security-architecture/SKILL.md`

## Primary Benchmark Prompts

1. `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`
2. `What is the weakest trust boundary in my current setup?`

## Artifact 1: Qwen 3 Thinking-Mode Correction

### Why this matters

The initial benchmark wrongly concluded that `qwen3:8b` and `qwen3:14b` were unusable because `message.content` was empty.

The raw API payload showed the real issue:

- Qwen 3 was emitting into `message.thinking`
- the run hit the token cap before producing final `content`

### Raw evidence excerpt

Model:

- `qwen3:8b`

Observed raw payload excerpt:

```json
{
  "message": {
    "role": "assistant",
    "content": "",
    "thinking": "Okay, the user is asking if their current OpenClaw architecture is sound..."
  },
  "done_reason": "length"
}
```

Interpretation:

- the earlier “empty output” judgment was invalid
- `think: false` was required for a fair benchmark

## Artifact 2: Tuned Comparison Excerpts

The excerpts below are from the corrected tuned pass:

- `temperature: 0.15`
- `num_predict: 400`
- `think: false` for Qwen 3

### `llama3.1:8b`

Prompt:

- `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`

Latency:

- `18120 ms`

Excerpt:

> “Based on the information provided (none), it's impossible to make a definitive statement...”

Why it matters:

- too deferential
- underuses known deployment context
- safer than some others, but not forceful enough for this role

### `qwen2.5:7b`

Prompt:

- `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`

Latency:

- `13647 ms`

Excerpt:

> “To determine whether your current OpenClaw architecture is sound... Let's break it down: Host vs. Container Boundary... Trust Boundaries... Authentication and Authorization...”

Why it matters:

- generic consultation structure
- turns into a broad checklist instead of a judgment about the actual OpenClaw shape

### `qwen3:8b`

Prompt:

- `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`

Latency:

- `15823 ms`

Excerpt:

> “Your current OpenClaw architecture is an interim design with significant trust boundary risks. It is not a sound architecture, and it appears to be layering workarounds...”

Why it matters:

- strongest direct judgment among the tested models
- discussion-first shape matches the intended topic better
- but the model still overstates some claims as if they were already verified

### `qwen3:14b`

Prompt:

- `What is the weakest trust boundary in my current setup?`

Latency:

- `106867 ms`

Excerpt:

> “The weakest trust boundary in your current setup is the Telegram channel integration...”

Why it matters:

- plausible answer shape
- but still overconfident about what has actually been established
- much slower than `qwen3:8b`

### `mistral-nemo:latest`

Prompt:

- `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`

Latency:

- `50216 ms`

Excerpt:

> “To provide an accurate assessment... I'll need some context about how it's set up.”

Why it matters:

- spends too much of the answer asking for rediscovery
- poor fit for a topic that already carries system context in the workspace prompt

### `gemma3:12b`

Prompt:

- `What is the weakest trust boundary in my current setup?`

Latency:

- `73915 ms`

Excerpt:

> “The weakest trust boundary is likely the plugin surface...”

Why it matters:

- structured answer
- still largely based on generic plugin-risk assumptions
- not tight enough to the actual OpenClaw deployment

## Artifact 3: Single-Run Candidate Findings

### `mistral-nemo:latest`

One dedicated single-run check produced:

- `126897 ms`
- direct request for more setup detail

Excerpt:

> “Please provide the relevant details so I can give you a more accurate assessment.”

This reinforced the tuned benchmark result:

- runnable
- but too context-seeking for this topic

### `gemma3:12b`

One dedicated single-run check produced:

- `189804 ms`
- answer shape was disciplined, but substance remained broad and provisional

Excerpt:

> “Your architecture likely contains elements of both a sound design and workarounds...”

This reinforced the tuned benchmark result:

- competent structure
- insufficient sharpness for the latency cost

## Artifact 4: Installed-and-Tested Candidate Inventory

Completed tested candidates:

- `llama3.1:8b`
- `qwen2.5:7b`
- `qwen3:8b`
- `qwen3:14b`
- `mistral-nemo:latest`
- `gemma3:12b`

Additional candidate installed after the tuned pass:

- `mistral-small:latest`

### `mistral-small:latest`

Prompt:

- `Is my current OpenClaw architecture actually sound, or am I just layering workarounds?`

Latency:

- `204660 ms`

Excerpt:

> “The current OpenClaw architecture appears to be an interim design with several workarounds in place...”

Why it matters:

- this is a complete answer
- but it is still generic at the substance level
- it spends a lot of tokens on broad review language without adding enough system-specific insight to justify the runtime cost

Second prompt:

- `What is the weakest trust boundary in my current setup?`
- `213125 ms`

Excerpt:

> “The weakest trust boundary in your current setup is likely between the host deployment environment and the containerized runtime...”

Why it matters:

- again defaults to generic host/container framing
- does not show enough OpenClaw-specific architectural sharpness

Assessment:

- better than `mistral-nemo`
- still not competitive enough to win

## Artifact 5: Shared-Context Finalist Comparison

Short shared context used:

- host machine
- WSL
- Docker gateway
- Telegram topics
- host bridge
- deterministic Host Control
- discussion-first Security Architecture
- recurring trust-boundary confusion between host, container, Telegram, plugins, and bridge

### `llama3.1:8b`

Latency:

- `20385 ms`

Excerpt:

> “Your current OpenClaw architecture is a mix of valid interim designs and potential long-term risks...”

Why it matters:

- better than its zero-context answer
- more usable once ambiguity is reduced
- still relatively cautious and less decisive

### `qwen3:8b` with `think: false`

Latency:

- `16257 ms`

Excerpt:

> “Your current OpenClaw architecture is an interim design that addresses immediate operational needs but lacks a clear, defined trust boundary...”

Why it matters:

- still the sharper reviewer
- stronger direct architectural judgment
- still slightly overassertive, but remains the stronger fit for this topic

## Evidence Interpretation Rules

When reading the excerpts in this file:

- a good result is not just fluent prose
- the key questions are:
  - did the model make a real architectural judgment?
  - did it use known context?
  - did it separate fact from inference?
  - did it avoid generic boilerplate?
  - did its latency justify the answer quality?

That is why some models with technically valid outputs were still rejected or downgraded.

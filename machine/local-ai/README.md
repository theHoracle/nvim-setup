# Local coding model

Configured for theHoracle's M2 Pro MacBook Pro with 32 GB unified memory.
Backend: Homebrew Ollama, bound to 127.0.0.1:11434, with local inference only.
Model: qwen3.5:9b-q4_K_M (about 6.6 GB download), aliased as local-dev.
Context: 65,536 tokens. One active request, one loaded model, Flash Attention,
q8_0 KV cache, idle unloading after five minutes. The server starts at login;
it does not preload a model. These settings constrain model memory demand,
but are not a hard system RAM reservation.

## Restore

```sh
brew install ollama
# Review/copy the launch agent, adjusting user-specific paths for another account.
cp xyz.thehoracle.ollama.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/xyz.thehoracle.ollama.plist
ollama pull qwen3.5:9b-q4_K_M
ollama create local-dev -f Modelfile
cp local.config.toml ~/.codex/local.config.toml
cp codex-local ~/.local/bin/codex-local
chmod +x ~/.local/bin/codex-local
```

Install Codex CLI if it is absent. Normal `codex` retains your cloud model settings.
`codex-local` selects the local model explicitly; it uses a separate local profile
with compaction at 49,152 tokens and web search disabled.

```sh
codex-local               # Interactive coding agent in the current directory
codex-local exec "Explain this project"
ollama run local-dev     # Direct chat
ollama ps                # See actual memory allocation and GPU use
ollama stop local-dev    # Release model memory immediately
```

## Hermes connection

For an existing Hermes installation, configure its local/custom provider with:

```yaml
model:
  default: local-dev
  provider: custom
  base_url: http://127.0.0.1:11434/v1
  context_length: 65536
  ollama_num_ctx: 65536
```

No API key is required by Ollama; use a dummy `ollama` value if a client requires
one. Hermes itself is not installed by this setup; Codex is the selected harness.
Local inference quality and speed vary by task and context size. This model is
intended for focused coding assistance and smaller tool workflows.

Sources: [model](https://ollama.com/library/qwen3.5:9b-q4_K_M),
[context sizing](https://docs.ollama.com/context-length),
[Codex options](https://learn.chatgpt.com/docs/config-file/config-reference),
[Hermes providers](https://hermes-agent.nousresearch.com/docs/integrations/providers).

On the configured Mac, `local-ai-status` reports download/validation progress. The temporary finishing job is managed by launchd, resumes at login if needed, and removes its launch-agent file after successful validation. Its logs and measured results live in `~/.local/share/local-ai-setup/`.

## Gemma comparison model

Gemma 4 12B Q4_K_M (`gemma4:12b-it-q4_K_M`, about 8 GB) is queued after
Qwen for download and validation. It uses the `gemma-dev` alias with a 65,536-token
context. Both models remain on disk; Ollama loads only one at a time.
Qwen remains the default. `local-ai-status` includes Gemma queue/check status.
After validation, use `codex-gemma` or `ollama run gemma-dev`.
The automatic comparison records a small TypeScript generation check, tool-call
check, token throughput and model allocation at the same context, plus a Gemma
Codex file-reading check. These are smoke checks, not a comprehensive model ranking.
Results live in `~/.local/share/local-ai-setup/work/gemma/comparison.json`.

To restore the extra model and command manually:

```sh
ollama pull gemma4:12b-it-q4_K_M
ollama create gemma-dev -f Gemma.Modelfile
cp codex-gemma ~/.local/bin/codex-gemma
chmod +x ~/.local/bin/codex-gemma
```

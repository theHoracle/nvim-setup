return {
	{
		-- Tell lazy.nvim this is a local plugin.
		dir = vim.fn.stdpath("config") .. "/lua/thehoracle/local/dingllm",
		name = "dingllm",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Require the local module
			local dingllm = require("thehoracle.local.dingllm")

			-- Define your prompts.
			local system_prompt =
				"You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks"
			local helpful_prompt = "You are a helpful assistant. What I have sent are my notes so far."

			------------------------------------------------------------------------------
			-- Define functions that call the LLM endpoints using your local module.
			------------------------------------------------------------------------------
			local function llama_405b_base()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://openrouter.ai/api/v1/chat/completions",
					model = "meta-llama/llama-3.1-405b",
					api_key_name = "OPEN_ROUTER_API_KEY",
					max_tokens = "128",
					replace = false,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function groq_replace()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.groq.com/openai/v1/chat/completions",
					model = "llama-3.3-70b-versatile", --  "deepseek-r1-distill-llama-70b",
					api_key_name = "GROQ_API_KEY",
					system_prompt = system_prompt,
					replace = true,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function groq_help()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.groq.com/openai/v1/chat/completions",
					model = "llama-3.3-70b-versatile", --  "deepseek-r1-distill-llama-70b",
					api_key_name = "GROQ_API_KEY",
					system_prompt = helpful_prompt,
					replace = false,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function llama405b_replace()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.lambdalabs.com/v1/chat/completions",
					model = "hermes-3-llama-3.1-405b-fp8",
					api_key_name = "LAMBDA_API_KEY",
					system_prompt = system_prompt,
					replace = true,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function llama405b_help()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.lambdalabs.com/v1/chat/completions",
					model = "hermes-3-llama-3.1-405b-fp8",
					api_key_name = "LAMBDA_API_KEY",
					system_prompt = helpful_prompt,
					replace = false,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function anthropic_help()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.anthropic.com/v1/messages",
					model = "claude-3-5-sonnet-20241022",
					api_key_name = "ANTHROPIC_API_KEY",
					system_prompt = helpful_prompt,
					replace = false,
				}, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
			end

			local function anthropic_replace()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.anthropic.com/v1/messages",
					model = "claude-3-5-sonnet-20241022",
					api_key_name = "ANTHROPIC_API_KEY",
					system_prompt = system_prompt,
					replace = true,
				}, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
			end

			------------------------------------------------------------------------------
			-- Map keybindings to the above functions.
			------------------------------------------------------------------------------
			vim.keymap.set({ "n", "v" }, "<leader>k", groq_replace, { desc = "LLM: Groq Replace" })
			vim.keymap.set({ "n", "v" }, "<leader>K", groq_help, { desc = "LLM: Groq Help" })
			vim.keymap.set({ "n", "v" }, "<leader>l", llama405b_replace, { desc = "LLM: Llama405b Replace" })
			vim.keymap.set({ "n", "v" }, "<leader>L", llama405b_help, { desc = "LLM: Llama405b Help" })
			vim.keymap.set({ "n", "v" }, "<leader>i", anthropic_replace, { desc = "LLM: Anthropic Replace" })
			vim.keymap.set({ "n", "v" }, "<leader>I", anthropic_help, { desc = "LLM: Anthropic Help" })
			vim.keymap.set({ "n", "v" }, "<leader>o", llama_405b_base, { desc = "LLM: Llama 405b Base" })
		end,
	},
}

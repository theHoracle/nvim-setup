local M = {}
local Job = require("plenary.job")

-- Helper: Get API key from environment.
local function get_api_key(name)
	return os.getenv(name)
end

-- Get lines from the beginning of the buffer until the cursor.
function M.get_lines_until_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(win)
	local row = cursor[1]
	local lines = vim.api.nvim_buf_get_lines(buf, 0, row, true)
	return table.concat(lines, "\n")
end

-- Get the current visual selection, if any.
function M.get_visual_selection()
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then
		local start = vim.fn.getpos("v")
		local finish = vim.fn.getpos(".")
		local srow, scol = start[2], start[3]
		local erow, ecol = finish[2], finish[3]
		if srow > erow then
			srow, erow = erow, srow
			scol, ecol = ecol, scol
		end
		local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
		return lines
	end
	return nil
end

-- Build curl arguments for an Anthropic API call.
function M.make_anthropic_spec_curl_args(opts, prompt, system_prompt)
	local url = opts.url
	local api_key = opts.api_key_name and get_api_key(opts.api_key_name)
	local data = {
		system = system_prompt,
		messages = { { role = "user", content = prompt } },
		model = opts.model,
		stream = true,
		max_tokens = 4096,
	}
	local args = {
		"-N",
		"-X",
		"POST",
		"-H",
		"Content-Type: application/json",
		"-d",
		vim.json.encode(data),
	}
	if api_key then
		table.insert(args, "-H")
		table.insert(args, "x-api-key: " .. api_key)
		table.insert(args, "-H")
		table.insert(args, "anthropic-version: 2023-06-01")
	end
	table.insert(args, url)
	return args
end

-- Build curl arguments for an OpenAI-compatible API call.
function M.make_openai_spec_curl_args(opts, prompt, system_prompt)
	local url = opts.url
	local api_key = opts.api_key_name and get_api_key(opts.api_key_name)
	local data = {
		messages = {
			{ role = "system", content = system_prompt },
			{ role = "user", content = prompt },
		},
		model = opts.model,
		temperature = 0.7,
		stream = true,
	}
	local args = {
		"-N",
		"-X",
		"POST",
		"-H",
		"Content-Type: application/json",
		"-d",
		vim.json.encode(data),
	}
	if api_key then
		table.insert(args, "-H")
		table.insert(args, "Authorization: Bearer " .. api_key)
	end
	table.insert(args, url)
	return args
end

-- Write a given string at the current cursor position in the active window.
function M.write_string_at_cursor(str)
	vim.schedule(function()
		local win = vim.api.nvim_get_current_win()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local row, col = cursor[1], cursor[2]
		local lines = vim.split(str, "\n")
		vim.cmd("undojoin")
		vim.api.nvim_put(lines, "c", true, true)
		local num_lines = #lines
		local last_line_length = #lines[num_lines]
		vim.api.nvim_win_set_cursor(win, { row + num_lines - 1, col + last_line_length })
	end)
end

-- Determine the prompt to send: visual selection or text until the cursor.
local function get_prompt(opts)
	local prompt = ""
	local visual = M.get_visual_selection()
	if visual and #visual > 0 then
		prompt = table.concat(visual, "\n")
		if opts.replace then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
			vim.cmd("normal! d")
		else
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		end
	else
		prompt = M.get_lines_until_cursor()
	end
	return prompt
end

-- Handle streamed data for Anthropic API responses.
function M.handle_anthropic_spec_data(data_stream, event_state)
	if event_state == "content_block_delta" then
		local ok, json = pcall(vim.json.decode, data_stream)
		if ok and json.delta and json.delta.text then
			M.write_string_at_cursor(json.delta.text)
		else
			vim.schedule(function()
				vim.notify("Anthropic: Error decoding JSON", vim.log.levels.DEBUG)
			end)
		end
	end
end

-- Handle streamed data for OpenAI-compatible API responses.
function M.handle_openai_spec_data(data_stream)
	if data_stream:match('"delta":') then
		local ok, json = pcall(vim.json.decode, data_stream)
		if ok and json.choices and json.choices[1] and json.choices[1].delta then
			local content = json.choices[1].delta.content
			if content then
				M.write_string_at_cursor(content)
			end
		else
			vim.schedule(function()
				vim.notify("OpenAI: Error decoding JSON", vim.log.levels.DEBUG)
			end)
		end
	end
end

-- Create an autogroup for cancellation events.
local group = vim.api.nvim_create_augroup("DING_LLM_AutoGroup", { clear = true })
local active_job = nil

-- Invoke the LLM and stream its output into the editor.
function M.invoke_llm_and_stream_into_editor(opts, make_curl_args_fn, handle_data_fn)
	vim.api.nvim_clear_autocmds({ group = group })
	local prompt = get_prompt(opts)
	local system_prompt = opts.system_prompt
		or "You are a tsundere uwu anime. Yell at me for not setting my configuration for my llm plugin correctly"
	local args = make_curl_args_fn(opts, prompt, system_prompt)

	-- Force the current window to wrap text to avoid horizontal scrolling.
	vim.schedule(function()
		vim.wo.wrap = true
	end)

	local curr_event_state = nil

	local function parse_and_call(line)
		local event = line:match("^event:%s*(.+)$")
		if event then
			curr_event_state = event
			return
		end
		local data_line = line:match("^data:%s*(.+)$")
		if data_line then
			handle_data_fn(data_line, curr_event_state)
		end
	end

	if active_job then
		active_job:shutdown()
		active_job = nil
	end

	active_job = Job:new({
		command = "curl",
		args = args,
		on_stdout = function(_, line)
			parse_and_call(line)
		end,
		on_stderr = function(_, err)
			vim.schedule(function()
				vim.notify("curl stderr: " .. tostring(err), vim.log.levels.DEBUG)
			end)
		end,
		on_exit = function(_, exit_code)
			vim.schedule(function()
				if exit_code ~= 0 then
					vim.notify("curl exited with code " .. exit_code, vim.log.levels.ERROR)
				end
				-- Redraw the screen to avoid the "Press ENTER" prompt.
				vim.cmd("redraw!")
			end)
			active_job = nil
		end,
	})

	active_job:start()

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "DING_LLM_Escape",
		callback = function()
			if active_job then
				active_job:shutdown()
				vim.schedule(function()
					vim.notify("LLM streaming cancelled", vim.log.levels.INFO)
				end)
				active_job = nil
			end
		end,
	})

	vim.api.nvim_set_keymap("n", "<Esc>", ":doautocmd User DING_LLM_Escape<CR>", { noremap = true, silent = true })
	return active_job
end

return M

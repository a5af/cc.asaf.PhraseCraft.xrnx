--[[============================================================================
http/https_client.lua
============================================================================]]--

-- HTTPS client implementation using curl system calls

local https_client = {}

--------------------------------------------------------------------------------
-- JSON Encoding/Decoding
--------------------------------------------------------------------------------

-- Simple JSON encoder (minimal implementation)
local function encode_json(data)
  if type(data) == "table" then
    local is_array = #data > 0
    local result = {}

    if is_array then
      for i, v in ipairs(data) do
        table.insert(result, encode_json(v))
      end
      return "[" .. table.concat(result, ",") .. "]"
    else
      for k, v in pairs(data) do
        local key = '"' .. tostring(k) .. '"'
        table.insert(result, key .. ":" .. encode_json(v))
      end
      return "{" .. table.concat(result, ",") .. "}"
    end
  elseif type(data) == "string" then
    -- Escape special characters
    local escaped = data:gsub("\\", "\\\\")
                        :gsub('"', '\\"')
                        :gsub("\n", "\\n")
                        :gsub("\r", "\\r")
                        :gsub("\t", "\\t")
    return '"' .. escaped .. '"'
  elseif type(data) == "number" then
    return tostring(data)
  elseif type(data) == "boolean" then
    return data and "true" or "false"
  elseif data == nil then
    return "null"
  else
    return '""'
  end
end

-- Simple JSON decoder (minimal implementation)
local function decode_json(str)
  -- Use Renoise's built-in JSON if available, otherwise fallback
  if renoise and renoise.tool and renoise.tool().parse_json then
    local success, result = pcall(function()
      return renoise.tool():parse_json(str)
    end)
    if success then
      return result
    end
  end

  -- Basic fallback parser (very limited, for simple responses)
  local obj = {}

  -- Try to extract content field (for Anthropic responses)
  local content = str:match('"content"%s*:%s*%[%s*{%s*"text"%s*:%s*"([^"]*)"')
  if content then
    obj.content = {{text = content}}
    return obj
  end

  -- Try to extract choices (for OpenAI responses)
  local message = str:match('"message"%s*:%s*{%s*"content"%s*:%s*"([^"]*)"')
  if message then
    obj.choices = {{message = {content = message}}}
    return obj
  end

  -- Try to extract error message
  local error = str:match('"error"%s*:%s*{.-"message"%s*:%s*"([^"]*)"')
  if error then
    obj.error = {message = error}
    return obj
  end

  return nil
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

-- Escape string for shell
local function shell_escape(str)
  if not str then return "" end

  -- For Windows, use different escaping
  if os.platform() == "WINDOWS" then
    -- Escape double quotes and backslashes
    return '"' .. str:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
  else
    -- For Unix-like systems, use single quotes and escape single quotes
    return "'" .. str:gsub("'", "'\\''") .. "'"
  end
end

-- Build headers for curl
local function build_header_args(headers)
  local args = {}
  for key, value in pairs(headers) do
    table.insert(args, "-H " .. shell_escape(key .. ": " .. value))
  end
  return table.concat(args, " ")
end

-- Check if curl is available
local function is_curl_available()
  local handle
  if os.platform() == "WINDOWS" then
    handle = io.popen("where curl 2>nul")
  else
    handle = io.popen("which curl 2>/dev/null")
  end

  if not handle then
    return false
  end

  local result = handle:read("*a")
  handle:close()
  return result and #result > 0
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Make HTTPS POST request
function https_client.post(url, headers, body, timeout)
  timeout = timeout or 30

  -- Check if curl is available
  if not is_curl_available() then
    return nil, "curl is not installed or not found in PATH"
  end

  -- Encode body to JSON
  local json_body = encode_json(body)

  -- Build curl command
  local header_args = build_header_args(headers)

  -- Create temporary file for request body
  local temp_file = os.tmpname()
  local file = io.open(temp_file, "w")
  if not file then
    return nil, "Failed to create temporary file"
  end
  file:write(json_body)
  file:close()

  -- Build curl command with temp file
  local curl_cmd = string.format(
    "curl -s -X POST --max-time %d %s -d @%s %s 2>&1",
    timeout,
    header_args,
    shell_escape(temp_file),
    shell_escape(url)
  )

  -- Execute curl
  local handle = io.popen(curl_cmd)
  if not handle then
    os.remove(temp_file)
    return nil, "Failed to execute curl command"
  end

  local response = handle:read("*a")
  local success = handle:close()

  -- Clean up temp file
  os.remove(temp_file)

  if not response or #response == 0 then
    return nil, "Empty response from server"
  end

  -- Check for curl errors
  if response:match("^curl:") or response:match("Could not resolve host") then
    return nil, "Network error: " .. response
  end

  -- Parse JSON response
  local data = decode_json(response)

  if not data then
    return nil, "Failed to parse JSON response: " .. response:sub(1, 200)
  end

  return data, nil
end

-- Make HTTPS GET request
function https_client.get(url, headers, timeout)
  timeout = timeout or 30

  if not is_curl_available() then
    return nil, "curl is not installed or not found in PATH"
  end

  local header_args = build_header_args(headers or {})

  local curl_cmd = string.format(
    "curl -s --max-time %d %s %s 2>&1",
    timeout,
    header_args,
    shell_escape(url)
  )

  local handle = io.popen(curl_cmd)
  if not handle then
    return nil, "Failed to execute curl command"
  end

  local response = handle:read("*a")
  handle:close()

  if not response or #response == 0 then
    return nil, "Empty response from server"
  end

  if response:match("^curl:") or response:match("Could not resolve host") then
    return nil, "Network error: " .. response
  end

  local data = decode_json(response)

  if not data then
    return nil, "Failed to parse JSON response: " .. response:sub(1, 200)
  end

  return data, nil
end

return https_client

-- Simple JSON parser for Yabai output
-- Handles the specific JSON format that Yabai produces

local json = {}

-- Simple JSON array/object parser
function json.parse(str)
  if not str or str == "" then
    return nil
  end
  
  -- Remove leading/trailing whitespace
  str = str:match("^%s*(.-)%s*$")
  
  -- Handle empty array
  if str == "[]" then
    return {}
  end
  
  -- Handle empty object  
  if str == "{}" then
    return {}
  end
  
  -- Use sbar.exec with jq to convert to simple format
  -- This is more reliable than parsing JSON in Lua
  local result = nil
  sbar.exec("echo '" .. str:gsub("'", "'\"'\"'") .. "' | jq -c . 2>/dev/null", function(jq_result)
    if jq_result and jq_result ~= "" then
      -- Try to parse as Lua table using load (only if it's clean JSON from jq)
      local success, parsed = pcall(function()
        -- Convert JSON to Lua table format
        local lua_str = jq_result:gsub("null", "nil"):gsub("true", "true"):gsub("false", "false")
        return load("return " .. lua_str)()
      end)
      if success then
        result = parsed
      end
    end
  end)
  
  return result or {}
end

-- Alternative: Use jq directly to parse and simplify
function json.parse_with_jq(str)
  if not str or str == "" then
    return {}
  end
  
  local result = {}
  sbar.exec("echo '" .. str:gsub("'", "'\"'\"'") .. "' | jq -c . 2>/dev/null", function(jq_result)
    if jq_result and jq_result ~= "" then
      -- For our use case, we can extract just what we need
      -- This is safer than full JSON parsing in Lua
      result = jq_result
    end
  end)
  
  return result
end

return json
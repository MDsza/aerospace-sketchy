-- Yabai Batch Query Manager v1.0
-- Reduces multiple yabai calls by batching queries into single operations

local yabai_batch = {}

-- Cache for batch results to prevent redundant queries
yabai_batch.cache = {
  data = {},
  timestamp = 0,
  ttl = 1 -- Cache valid for 1 second
}

-- Batch query all Yabai information in single command
function yabai_batch:query_all(callback)
  local now = os.time()
  
  -- Return cached data if still valid
  if self.cache.data.spaces and 
     self.cache.data.windows and 
     self.cache.data.displays and
     (now - self.cache.timestamp) < self.cache.ttl then
    
    if callback then
      callback(self.cache.data)
    end
    return self.cache.data
  end
  
  -- Optimized: Use separate calls for better reliability
  local batch_data = { timestamp = now }
  local calls_remaining = 3
  
  local function check_completion()
    calls_remaining = calls_remaining - 1
    if calls_remaining == 0 then
      -- Update cache
      self.cache.data = batch_data
      self.cache.timestamp = now
      
      if callback then
        callback(batch_data)
      end
    end
  end
  
  -- Enhanced parallel queries with jq-based JSON parsing
  sbar.exec('yabai -m query --displays 2>/dev/null | jq -c "[.[]|{index:.index,frame:.frame,\"has-focus\":.[\"has-focus\"]}]" 2>/dev/null', function(result)
    if result and result ~= "" and result ~= "[]" then
      -- Simple parsing for our specific display format
      batch_data.displays = result
    else
      batch_data.displays = {}
    end
    check_completion()
  end)
  
  sbar.exec('yabai -m query --spaces 2>/dev/null | jq -c "[.[]|{index:.index,display:.display,windows:.windows,\"has-focus\":.[\"has-focus\"]}]" 2>/dev/null', function(result)
    if result and result ~= "" and result ~= "[]" then
      batch_data.spaces = result
    else
      batch_data.spaces = {}
    end
    check_completion()
  end)
  
  sbar.exec('yabai -m query --windows 2>/dev/null | jq -c "[.[]|{id:.id,app:.app,space:.space,display:.display}]" 2>/dev/null', function(result)
    if result and result ~= "" and result ~= "[]" then
      batch_data.windows = result
    else
      batch_data.windows = {}
    end
    check_completion()
  end)
end

-- Get specific information from batch data
function yabai_batch:get_current_space(batch_data, callback)
  if not batch_data or not batch_data.spaces then
    if callback then callback(nil) end
    return nil
  end
  
  for _, space in ipairs(batch_data.spaces) do
    if space["has-focus"] then
      if callback then callback(space) end
      return space
    end
  end
  
  if callback then callback(nil) end
  return nil
end

-- Get windows for specific space
function yabai_batch:get_space_windows(batch_data, space_id, callback)
  if not batch_data or not batch_data.windows then
    if callback then callback({}) end
    return {}
  end
  
  local space_windows = {}
  for _, window in ipairs(batch_data.windows) do
    if window.space == space_id then
      table.insert(space_windows, window)
    end
  end
  
  if callback then callback(space_windows) end
  return space_windows
end

-- Get display information
function yabai_batch:get_displays(batch_data, callback)
  local displays = batch_data and batch_data.displays or {}
  if callback then callback(displays) end
  return displays
end

-- Optimized space info for SketchyBar spaces widget
function yabai_batch:get_spaces_summary(callback)
  self:query_all(function(batch_data)
    local summary = {
      spaces = {},
      current_space = nil,
      total_spaces = 0
    }
    
    if batch_data and batch_data.spaces then
      for _, space in ipairs(batch_data.spaces) do
        local space_info = {
          index = space.index,
          display = space.display,
          has_focus = space["has-focus"] or false,
          windows = space.windows or {},
          window_count = space.windows and #space.windows or 0
        }
        
        table.insert(summary.spaces, space_info)
        
        if space_info.has_focus then
          summary.current_space = space_info
        end
      end
      
      summary.total_spaces = #summary.spaces
    end
    
    if callback then
      callback(summary)
    end
  end)
end

-- Optimized window summary for performance
function yabai_batch:get_windows_summary(callback)
  self:query_all(function(batch_data)
    local summary = {
      total_windows = 0,
      apps = {},
      focused_window = nil
    }
    
    if batch_data and batch_data.windows then
      for _, window in ipairs(batch_data.windows) do
        summary.total_windows = summary.total_windows + 1
        
        -- Count windows per app
        local app = window.app or "Unknown"
        summary.apps[app] = (summary.apps[app] or 0) + 1
        
        -- Track focused window
        if window["has-focus"] then
          summary.focused_window = {
            app = app,
            title = window.title or "",
            space = window.space
          }
        end
      end
    end
    
    if callback then
      callback(summary)
    end
  end)
end

-- Force refresh cache (useful for events)
function yabai_batch:refresh()
  self.cache.timestamp = 0
  self.cache.data = {}
end

-- Initialize batch manager
function yabai_batch:init()
  print("YabaiBatch: Initialized batch query manager")
  
  -- Periodic cache cleanup
  sbar.add("item", "yabai_batch.cleanup", {
    position = "right",
    width = 0,
    update_freq = 30
  }):subscribe("routine", function()
    local now = os.time()
    if (now - self.cache.timestamp) > (self.cache.ttl * 5) then
      self:refresh()
    end
  end)
end

return yabai_batch
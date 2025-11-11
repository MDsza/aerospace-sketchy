-- Update Manager v1.0 - Centralized widget update coordination
-- Optimizes performance by batching system calls and coordinating update frequencies

local update_manager = {}

-- Update intervals (in seconds) - centralized configuration
update_manager.intervals = {
  cpu = 2,         -- High frequency for responsive CPU monitoring
  memory = 3,      -- Medium frequency for memory usage
  network = 2,     -- High frequency for network activity
  disk = 30,       -- Low frequency - disk usage changes slowly
  battery = 5,     -- Medium frequency for battery status
  temperature = 2, -- High frequency for thermal monitoring
  volume = 1,      -- Highest frequency for immediate feedback
  wifi = 10,       -- Low frequency - WiFi state changes rarely
  claude_notifier = 2, -- High frequency for Claude Code waiting detection
}

-- Debug configuration
update_manager.debug = {
  enabled = false,        -- Set to true for development debugging
  heartbeat_interval = 60, -- Debug heartbeat every 60 updates (1 minute)
  log_updates = false,    -- Log individual widget updates
  log_cache = false       -- Log cache operations
}

-- Track last update times to prevent over-polling
update_manager.last_updates = {}

-- Registered update callbacks
update_manager.callbacks = {}

-- System command cache to prevent duplicate calls
update_manager.cache = {
  data = {},
  timestamps = {},
  ttl = 1.5 -- Balanced Cache TTL - responsive but not excessive
}

-- Register a widget for managed updates
function update_manager:register(widget_name, callback, interval_key)
  interval_key = interval_key or widget_name
  
  self.callbacks[widget_name] = {
    callback = callback,
    interval = self.intervals[interval_key] or 5, -- Default 5s if not found
    last_update = 0
  }
  
  if self.debug.enabled then
    print("UpdateManager: Registered " .. widget_name .. " with " .. 
          (self.intervals[interval_key] or 5) .. "s interval")
  end
end

-- Check if widget needs update based on interval
function update_manager:should_update(widget_name)
  local widget = self.callbacks[widget_name]
  if not widget then return false end
  
  local now = os.time()
  return (now - widget.last_update) >= widget.interval
end

-- Execute cached system command
function update_manager:exec_cached(command, cache_key, callback)
  cache_key = cache_key or command
  local now = os.time()
  
  -- Check cache first
  if self.cache.data[cache_key] and 
     self.cache.timestamps[cache_key] and
     (now - self.cache.timestamps[cache_key]) < self.cache.ttl then
    
    if callback then
      callback(self.cache.data[cache_key])
    end
    return self.cache.data[cache_key]
  end
  
  -- Execute and cache result
  sbar.exec(command, function(result)
    self.cache.data[cache_key] = result
    self.cache.timestamps[cache_key] = now
    
    if callback then
      callback(result)
    end
  end)
end

-- Batch system information collection
function update_manager:collect_system_info(callback)
  -- Expanded system info collection
  local batch_cmd = [[
    CPU_LOAD=$(top -l 1 -n 0 | grep 'CPU usage' | awk '{gsub(/%/, "", $3); print $3}' 2>/dev/null || echo '0')
    MEMORY_USAGE=$(vm_stat | awk '/Pages active/ {active=$3} /Pages free/ {free=$3} END {gsub(/\./,"",active); gsub(/\./,"",free); total=active+free; if(total>0) print int((active/total)*100); else print 0}' 2>/dev/null || echo '0')
    DISK_USAGE=$(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5}' 2>/dev/null || echo '0')
    
    echo "CPU:$CPU_LOAD"
    echo "MEMORY:$MEMORY_USAGE"
    echo "DISK:$DISK_USAGE"
    echo "TIMESTAMP:$(date +%s)"
  ]]
  
  self:exec_cached(batch_cmd, "system_info", function(result)
    local system_info = { timestamp = os.time() }
    
    -- Parse key-value pairs
    for line in result:gmatch("[^\r\n]+") do
      local key, value = line:match("([^:]+):([^:]+)")
      if key and value then
        local num_value = tonumber(value)
        if num_value then
          system_info[key:lower()] = num_value
        end
      end
    end
    
    -- Set defaults if parsing failed
    system_info.cpu = system_info.cpu or 0
    system_info.memory = system_info.memory or 0
    system_info.disk = system_info.disk or 0
    
    if callback then
      callback(system_info)
    end
  end)
end

-- Main update routine - called by timer
function update_manager:update_all()
  local now = os.time()
  
  -- Check which widgets need updates
  local widgets_to_update = {}
  for widget_name, widget in pairs(self.callbacks) do
    if self:should_update(widget_name) then
      table.insert(widgets_to_update, widget_name)
    end
  end
  
  if #widgets_to_update == 0 then
    return -- No widgets need updating
  end
  
  if self.debug.log_updates then
    print("UpdateManager: Updating " .. #widgets_to_update .. " widgets: " .. table.concat(widgets_to_update, ", "))
  end
  
  -- Batch collect system info for efficiency
  self:collect_system_info(function(system_info)
    -- Update widgets that needed refreshing
    for widget_name, widget in pairs(self.callbacks) do
      if self:should_update(widget_name) then
        widget.callback(system_info)
        widget.last_update = now
        if self.debug.log_updates then
          print("UpdateManager: Updated " .. widget_name)
        end
      end
    end
  end)
end

-- Clean old cache entries
function update_manager:cleanup_cache()
  local now = os.time()
  
  for key, timestamp in pairs(self.cache.timestamps) do
    if (now - timestamp) > (self.cache.ttl * 3) then
      self.cache.data[key] = nil
      self.cache.timestamps[key] = nil
    end
  end
end

-- Initialize update manager with global timer
function update_manager:init()
  if self.debug.enabled then
    print("UpdateManager: Initializing centralized update system")
  end
  
  -- Initialize tracking variables
  self.initialized = true
  self.update_count = 0
  
  -- Create master update timer (1 second tick for precision)
  local timer_item = sbar.add("item", "update_manager.timer", {
    position = "right",
    width = 0,
    update_freq = 1
  })
  
  timer_item:subscribe("routine", function()
    self.update_count = self.update_count + 1
    
    -- Debug heartbeat (reduced frequency)
    if self.debug.enabled and (self.update_count % self.debug.heartbeat_interval == 0) then
      print("UpdateManager: Heartbeat #" .. self.update_count .. " - " .. 
            "Registered widgets: " .. self:count_widgets())
    end
    
    self:update_all()
    
    -- Periodic cache cleanup (every 30 seconds)
    if self.update_count % 30 == 0 then
      self:cleanup_cache()
      if self.debug.log_cache then
        print("UpdateManager: Cache cleanup performed")
      end
    end
  end)
  
  if self.debug.enabled then
    print("UpdateManager: Master timer created with 1s precision")
    print("UpdateManager: Initialization complete")
  end
end

-- Get system info for immediate use (bypasses intervals)
function update_manager:get_immediate_system_info(callback)
  self:collect_system_info(callback)
end

-- Adjust update frequency for a widget
function update_manager:set_interval(widget_name, new_interval)
  if self.callbacks[widget_name] then
    self.callbacks[widget_name].interval = new_interval
    if self.debug.enabled then
      print("UpdateManager: Updated " .. widget_name .. " interval to " .. new_interval .. "s")
    end
  end
end

-- Count registered widgets
function update_manager:count_widgets()
  local count = 0
  for _ in pairs(self.callbacks) do
    count = count + 1
  end
  return count
end

-- Get status information
function update_manager:get_status()
  return {
    initialized = self.initialized or false,
    update_count = self.update_count or 0,
    widget_count = self:count_widgets(),
    cache_entries = self:count_cache_entries()
  }
end

-- Count cache entries
function update_manager:count_cache_entries()
  local count = 0
  for _ in pairs(self.cache.data) do
    count = count + 1
  end
  return count
end

-- Enable/disable debug mode at runtime
function update_manager:enable_debug(enabled)
  self.debug.enabled = enabled or true
  self.debug.log_updates = enabled or true 
  self.debug.log_cache = enabled or true
  if enabled then
    print("UpdateManager: Debug mode enabled")
  else
    print("UpdateManager: Debug mode disabled") 
  end
end

return update_manager
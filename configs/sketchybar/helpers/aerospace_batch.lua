-- Aerospace Batch Query Manager v1.0
-- Optimized queries for Aerospace workspaces and windows

local aerospace_batch = {}

-- Cache for batch results to prevent redundant queries
aerospace_batch.cache = {
  data = {},
  timestamp = 0,
  ttl = 1 -- Cache valid for 1 second
}

-- Batch query all Aerospace information
function aerospace_batch:query_all(callback)
  local now = os.time()

  -- Return cached data if still valid
  if self.cache.data.workspaces and
     self.cache.data.windows and
     self.cache.data.focused_workspace and
     (now - self.cache.timestamp) < self.cache.ttl then

    if callback then
      callback(self.cache.data)
    end
    return self.cache.data
  end

  -- Execute batch queries
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

  -- Query 1: All workspaces
  sbar.exec('aerospace list-workspaces --all 2>/dev/null', function(result)
    batch_data.workspaces = {}
    if result and result ~= "" then
      for workspace in result:gmatch("[^\r\n]+") do
        local trimmed = workspace:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
          table.insert(batch_data.workspaces, { name = trimmed })
        end
      end
    end
    check_completion()
  end)

  -- Query 2: Focused workspace
  sbar.exec('aerospace list-workspaces --focused 2>/dev/null', function(result)
    batch_data.focused_workspace = result and result:match("^%s*(.-)%s*$") or nil
    check_completion()
  end)

  -- Query 3: All windows with workspace info
  sbar.exec('aerospace list-windows --all --format "%{workspace}|%{app-name}" 2>/dev/null', function(result)
    batch_data.windows = {}
    if result and result ~= "" then
      for line in result:gmatch("[^\r\n]+") do
        local workspace, app = line:match("^(.+)|(.+)$")
        if workspace and app then
          table.insert(batch_data.windows, {
            workspace = workspace,
            app = app
          })
        end
      end
    end
    check_completion()
  end)
end

-- Get windows for specific workspace
function aerospace_batch:get_workspace_windows(batch_data, workspace_name, callback)
  if not batch_data or not batch_data.windows then
    if callback then callback({}) end
    return {}
  end

  local workspace_windows = {}
  for _, window in ipairs(batch_data.windows) do
    if window.workspace == workspace_name then
      table.insert(workspace_windows, window)
    end
  end

  if callback then callback(workspace_windows) end
  return workspace_windows
end

-- Batch query with monitor information
function aerospace_batch:query_with_monitors(callback)
  local now = os.time()
  local batch_data = { timestamp = now }
  local calls_remaining = 4

  local function check_completion()
    calls_remaining = calls_remaining - 1
    if calls_remaining == 0 then
      if callback then
        callback(batch_data)
      end
    end
  end

  -- Query 1: All monitors
  sbar.exec('aerospace list-monitors --format "%{monitor-id}|%{monitor-name}" 2>/dev/null', function(result)
    batch_data.monitors = {}
    if result and result ~= "" then
      for line in result:gmatch("[^\r\n]+") do
        local id, name = line:match("^(%d+)|(.+)$")
        if id and name then
          table.insert(batch_data.monitors, {
            id = tonumber(id),
            name = name:match("^%s*(.-)%s*$"),
            is_builtin = name:match("Built%-in") ~= nil
          })
        end
      end
    end
    check_completion()
  end)

  -- Query 2: All workspaces with monitor assignment
  sbar.exec('aerospace list-workspaces --all --format "%{workspace}|%{monitor-id}|%{monitor-name}" 2>/dev/null', function(result)
    batch_data.workspaces = {}
    if result and result ~= "" then
      for line in result:gmatch("[^\r\n]+") do
        local workspace, monitor_id, monitor_name = line:match("^(.+)|(%d+)|(.+)$")
        if workspace and monitor_id then
          table.insert(batch_data.workspaces, {
            name = workspace:match("^%s*(.-)%s*$"),
            monitor_id = tonumber(monitor_id),
            monitor_name = monitor_name and monitor_name:match("^%s*(.-)%s*$") or nil
          })
        end
      end
    end
    check_completion()
  end)

  -- Query 3: Focused workspace
  sbar.exec('aerospace list-workspaces --focused 2>/dev/null', function(result)
    batch_data.focused_workspace = result and result:match("^%s*(.-)%s*$") or nil
    check_completion()
  end)

  -- Query 4: All windows with workspace and monitor info
  sbar.exec('aerospace list-windows --all --format "%{workspace}|%{app-name}|%{monitor-id}" 2>/dev/null', function(result)
    batch_data.windows = {}
    if result and result ~= "" then
      for line in result:gmatch("[^\r\n]+") do
        local workspace, app, monitor_id = line:match("^(.+)|(.+)|(%d+)$")
        if workspace and app and monitor_id then
          table.insert(batch_data.windows, {
            workspace = workspace,
            app = app,
            monitor_id = tonumber(monitor_id)
          })
        end
      end
    end
    check_completion()
  end)
end

-- Force refresh cache (useful for events)
function aerospace_batch:refresh()
  self.cache.timestamp = 0
  self.cache.data = {}
end

-- Initialize batch manager
function aerospace_batch:init()
  print("AerospaceBatch: Initialized batch query manager")

  -- Periodic cache cleanup
  sbar.add("item", "aerospace_batch.cleanup", {
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

return aerospace_batch

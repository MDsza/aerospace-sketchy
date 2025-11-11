local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local update_manager = require("helpers.update_manager")

-- =============================================================================
-- DISK FREE WIDGET REMOVED - Now handled by system_status widget
-- =============================================================================

-- =============================================================================
-- DISK ACTIVITY WIDGET - Read/Write Graphs (LABELS REMOVED)
-- =============================================================================

-- Disk Read Graph (Green) - Pure graph only, no labels
local disk_read = sbar.add("graph", "widgets.disk.read", 21, {
  position = "right",
  update_freq = 2,      -- Unified 2-second updates
  graph = {
    color = colors.green,
    fill_color = colors.green,
    line_width = 1.5,
    height = 20          -- Compact height
  },
  background = {
    height = 24,         -- Reduced background
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = false,     -- No visible background
  },
  icon = {
    string = "↑",
    color = colors.green,
    font = { size = 8 },
    padding_left = 1,
    padding_right = 1
  },
  label = { drawing = false },  -- No labels for clean layout
  padding_right = 1,
  padding_left = 0,
  popup = {
    align = "right",
    drawing = false,
    y_offset = -12,
    x_offset = -30,
    background = {
      color = colors.black,
      corner_radius = 6,
      shadow = { drawing = true },
      padding_left = 12,
      padding_right = 12,
      padding_top = 8,
      padding_bottom = 8,
      drawing = true
    }
  }
})

-- Disk Write Graph (Red) - Pure graph only, no labels
local disk_write = sbar.add("graph", "widgets.disk.write", 21, {
  position = "right",
  update_freq = 2,      -- Unified 2-second updates
  graph = {
    color = colors.red,
    fill_color = colors.red,
    line_width = 1.5,
    height = 20          -- Compact height
  },
  background = {
    height = 24,         -- Reduced background
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = false,     -- No visible background
  },
  icon = {
    string = "↓",
    color = colors.red,
    font = { size = 8 },
    padding_left = 1,
    padding_right = 1
  },
  label = { drawing = false },  -- No labels for clean layout
  padding_right = 1,
  padding_left = 0,
  popup = {
    align = "right",
    drawing = false,
    y_offset = -12,
    x_offset = -30,
    background = {
      color = colors.black,
      corner_radius = 6,
      shadow = { drawing = true },
      padding_left = 12,
      padding_right = 12,
      padding_top = 8,
      padding_bottom = 8,
      drawing = true
    }
  }
})

-- Track disk activity history for dynamic scaling
local read_history = {}
local write_history = {}
local max_activity_history = 5

-- Function to get disk activity (read/write)
local function update_disk_activity()
  -- Simplified disk IO parsing using a more straightforward approach
  local cmd = [[/usr/sbin/ioreg -l -r -c IOBlockStorageDriver | /usr/bin/grep -oE '"Bytes \([RW][^"]*\)"=[0-9]+|"Bytes [rw][^"]*device"=[0-9]+' | /usr/bin/awk -F= '{if(/Read|read/) r+=$2; if(/Write|write/) w+=$2} END {printf "%d %d\n", (r?r:0), (w?w:0)}']]
  sbar.exec(cmd, function(result)
    local bytes_read, bytes_written = (result or ""):match("(%d+)%s+(%d+)")
    local now = os.time()
    if not bytes_read or not bytes_written then 
      return 
    end

    bytes_read = tonumber(bytes_read)
    bytes_written = tonumber(bytes_written)

    -- Initialize on first run
    if not disk_read.prev_bytes_read then
      disk_read.prev_bytes_read = bytes_read
      disk_write.prev_bytes_written = bytes_written
      disk_read.prev_time = now
      return
    end

    local dt = math.max(2, now - (disk_read.prev_time or now))  -- Expect ~2 second intervals
    local read_mb = math.max(0, (bytes_read - disk_read.prev_bytes_read) / (1024 * 1024) / dt)
    local write_mb = math.max(0, (bytes_written - disk_write.prev_bytes_written) / (1024 * 1024) / dt)

    -- Store for next iteration and current rates for popups
    disk_read.prev_bytes_read = bytes_read
    disk_write.prev_bytes_written = bytes_written
    disk_read.prev_time = now
    disk_read.current_rate = read_mb
    disk_write.current_rate = write_mb

    -- Add to history for dynamic scaling
    table.insert(read_history, read_mb)
    table.insert(write_history, write_mb)
    if #read_history > max_activity_history then
      table.remove(read_history, 1)
      table.remove(write_history, 1)
    end

    -- Calculate dynamic scaling (similar to network widgets)
    local max_read = 0
    local max_write = 0
    for _, val in ipairs(read_history) do max_read = math.max(max_read, val) end
    for _, val in ipairs(write_history) do max_write = math.max(max_write, val) end

    -- Use realistic scales like iStat Menus - much less sensitive
    local scale_max_read = math.max(max_read * 2, 50)   -- At least 50 MB/s scale (like iStat)
    local scale_max_write = math.max(max_write * 2, 20) -- At least 20 MB/s scale (like iStat)
    
    local normalized_read = math.min(math.max(read_mb, 0) / scale_max_read, 1.0)
    local normalized_write = math.min(math.max(write_mb, 0) / scale_max_write, 1.0)

    disk_read:push({ normalized_read })
    disk_write:push({ normalized_write })
    
    -- Dynamic transparency based on disk activity - unified with other widgets
    -- Read: 0.25 (25%) at 0 MB/s → 0.55 (55%) at scale_max_read
    local read_activity_ratio = read_mb / scale_max_read
    local read_alpha = math.max(0.25, math.min(0.55, 0.25 + read_activity_ratio * 0.3))
    local read_color = colors.with_alpha(colors.green, read_alpha)

    -- Write: 0.25 (25%) at 0 MB/s → 0.55 (55%) at scale_max_write
    local write_activity_ratio = write_mb / scale_max_write
    local write_alpha = math.max(0.25, math.min(0.55, 0.25 + write_activity_ratio * 0.3))
    local write_color = colors.with_alpha(colors.red, write_alpha)
    
    -- Update colors dynamically
    disk_read:set({
      graph = { color = read_color, fill_color = read_color },
      icon = { color = read_color }
    })
    
    disk_write:set({
      graph = { color = write_color, fill_color = write_color },
      icon = { color = write_color }
    })
  end)
end

-- Subscribe widgets to updates
-- Removed individual timer - managed centrally by update manager

-- Register with centralized update manager
update_manager:register("disk_activity", function(system_info)
  update_disk_activity()  -- Keep detailed disk I/O monitoring  
end, "network")  -- Use network interval (2s) instead of disk (30s) for responsive I/O graphs

-- Simplified initialization - update manager handles timing

-- Initial readings
update_disk_activity()

-- Smart Disk Utility Toggle for both I/O widgets
local function toggle_disk_utility()
  -- Check if Disk Utility is already open
  sbar.exec([[pgrep -f "Disk Utility"]], function(result)
    if result and result:match("%d+") then
      -- Disk Utility is open, close it
      sbar.exec([[osascript -e "tell application \"Disk Utility\" to quit"]])
    else
      -- Disk Utility is closed, open it
      sbar.exec([[open -a "Disk Utility"]])
    end
  end)
end

-- Mouse click handlers - Open Disk Utility with toggle
disk_read:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    toggle_disk_utility()
  end
end)

-- Disk Read Popup Items
local disk_read_current_item = sbar.add("item", {
  position = "popup." .. disk_read.name,
  icon = { drawing = false },
  label = {
    string = "↑ 0.0 MB/s",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    color = colors.green,
    align = "center",
    width = 120,
  },
})

local disk_read_info_item = sbar.add("item", {
  position = "popup." .. disk_read.name,
  icon = { drawing = false },
  label = {
    string = "Disk Read Activity",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 11.0,
    },
    color = colors.grey,
    align = "center",
    width = 120,
  },
})

-- Disk Write Popup Items  
local disk_write_current_item = sbar.add("item", {
  position = "popup." .. disk_write.name,
  icon = { drawing = false },
  label = {
    string = "↓ 0.0 MB/s",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    color = colors.red,
    align = "center",
    width = 120,
  },
})

local disk_write_info_item = sbar.add("item", {
  position = "popup." .. disk_write.name,
  icon = { drawing = false },
  label = {
    string = "Disk Write Activity",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 11.0,
    },
    color = colors.grey,
    align = "center",
    width = 120,
  },
})

-- Enhanced hover handlers with continuous updates like CPU widget
local disk_read_popup_active = false
local disk_write_popup_active = false

-- Function to update disk popup data
local function update_disk_popup_data()
  local read_rate = disk_read.current_rate or 0
  local write_rate = disk_write.current_rate or 0
  
  if disk_read_popup_active then
    disk_read_current_item:set({
      label = {
        string = string.format("↑ %.1f MB/s", read_rate),
        color = read_rate > 5 and colors.green or colors.grey
      }
    })
    disk_read_info_item:set({
      label = {
        string = read_rate > 10 and "High Activity" or read_rate > 1 and "Moderate Activity" or "Low Activity"
      }
    })
  end
  
  if disk_write_popup_active then
    disk_write_current_item:set({
      label = {
        string = string.format("↓ %.1f MB/s", write_rate),
        color = write_rate > 5 and colors.red or colors.grey
      }
    })
    disk_write_info_item:set({
      label = {
        string = write_rate > 10 and "High Activity" or write_rate > 1 and "Moderate Activity" or "Low Activity"
      }
    })
  end
end

-- Disk Read hover handlers
disk_read:subscribe("mouse.entered", function(env)
  disk_read_popup_active = true
  disk_read:set({ popup = { drawing = true } })
  -- Immediate update when popup opens
  update_disk_popup_data()
  -- Then start periodic refresh
  local function refresh()
    if not disk_read_popup_active then return end
    update_disk_popup_data()
    sbar.delay(2, refresh)  -- 2-second updates
  end
  sbar.delay(2, refresh)
end)

disk_read:subscribe("mouse.exited", function(env)
  disk_read_popup_active = false
  disk_read:set({ popup = { drawing = false } })
end)

-- Disk Write hover handlers
disk_write:subscribe("mouse.entered", function(env)
  disk_write_popup_active = true
  disk_write:set({ popup = { drawing = true } })
  -- Immediate update when popup opens
  update_disk_popup_data()
  -- Then start periodic refresh
  local function refresh()
    if not disk_write_popup_active then return end
    update_disk_popup_data()
    sbar.delay(2, refresh)  -- 2-second updates
  end
  sbar.delay(2, refresh)
end)

disk_write:subscribe("mouse.exited", function(env)
  disk_write_popup_active = false
  disk_write:set({ popup = { drawing = false } })
end)

disk_write:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    toggle_disk_utility()
  end
end)

-- Background brackets - transparent for clean look
sbar.add("bracket", "widgets.disk.activity.bracket", 
  { disk_read.name, disk_write.name }, 
  { background = { color = colors.transparent, drawing = false } }
)

-- Padding
sbar.add("item", "widgets.disk.padding", {
  position = "right",
  width = settings.group_paddings
})

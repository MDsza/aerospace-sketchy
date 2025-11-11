local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local update_manager = require("helpers.update_manager")  -- Load update_manager explicitly

-- Memory/RAM Graph Widget - Shows system memory usage with dynamic visualization
local memory = sbar.add("graph", "widgets.memory", 42, {
  position = "right",
  update_freq = 3,
  graph = {
    color = colors.blue,
    fill_color = colors.with_alpha(colors.blue, 0.3),  -- 30% fill visibility
    line_width = 2.0,
    height = 20          -- Compact height matching CPU
  },
  background = {
    height = 24,         -- Reduced background
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = false,     -- No visible background
  },
  icon = {
    string = "◉",        -- Memory indicator icon
    color = colors.blue,
    font = { size = 8 },
    padding_left = 2,
    padding_right = 2
  },
  label = { drawing = false },  -- No labels for clean layout
  padding_right = settings.paddings + 6,
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

-- Memory display update function
local function update_memory_display(usage_pct, used_gb, total_gb)
  -- Dynamic scaling: Show only relevant range (40% = baseline, 100% = max)
  -- macOS typically uses 30-40% minimum (system + kernel), so 40% baseline is realistic
  local min_baseline = 40.0
  local max_range = 100.0 - min_baseline  -- 60% range

  -- Normalize: 40% -> 0.0 (bottom), 100% -> 1.0 (top)
  -- Values below baseline are clamped to 0, above 100% clamped to 1
  local normalized = math.min(math.max((usage_pct - min_baseline) / max_range, 0), 1.0)
  memory:push({ normalized })

  -- Dynamic color intensity based on memory pressure
  local base_color = colors.blue
  if usage_pct > 85 then
    base_color = colors.red    -- Critical memory pressure
  elseif usage_pct > 75 then
    base_color = colors.orange -- High memory usage
  elseif usage_pct > 60 then
    base_color = colors.yellow -- Elevated memory usage
  end

  -- Calculate dynamic alpha: 0.2 (20%) at low usage → 0.6 (60%) at high usage
  -- More transparent like other widgets, higher usage = slightly brighter
  local alpha = math.max(0.2, math.min(0.6, 0.2 + (usage_pct / 100.0) * 0.4))
  local dynamic_color = colors.with_alpha(base_color, alpha)

  memory:set({
    graph = { color = dynamic_color },
    icon  = { color = dynamic_color }
  })
end

-- Optimized memory update function using centralized system info
local function update_memory(system_info)
  -- Get detailed memory statistics via vm_stat
  sbar.exec("vm_stat | head -10", function(vm_result)
    if not vm_result then return end

    -- Parse vm_stat output for accurate memory accounting
    -- macOS Apple Silicon uses 16KB pages (Intel uses 4KB)
    local page_size = 16384

    local pages_free = tonumber(vm_result:match("Pages free:%s*(%d+)")) or 0
    local pages_active = tonumber(vm_result:match("Pages active:%s*(%d+)")) or 0
    local pages_inactive = tonumber(vm_result:match("Pages inactive:%s*(%d+)")) or 0
    local pages_wired = tonumber(vm_result:match("Pages wired down:%s*(%d+)")) or 0
    local pages_compressed = tonumber(vm_result:match("Pages occupied by compressor:%s*(%d+)")) or 0

    -- Calculate memory usage (macOS convention)
    -- Used = active + wired + compressed (inactive is AVAILABLE, not used!)
    local used_pages = pages_active + pages_wired + pages_compressed
    local available_pages = pages_free + pages_inactive
    local total_pages = used_pages + available_pages

    -- Convert to GB
    local used_gb = (used_pages * page_size) / (1024 * 1024 * 1024)
    local free_gb = (pages_free * page_size) / (1024 * 1024 * 1024)  -- FIXED: was free_pages
    local total_gb = (total_pages * page_size) / (1024 * 1024 * 1024)

    local usage_pct = total_pages > 0 and (used_pages / total_pages * 100) or 0

    update_memory_display(usage_pct, used_gb, total_gb)
  end)
end

-- Register with centralized update manager
update_manager:register("memory", update_memory, "memory")

-- Memory Popup Items
local memory_usage_item = sbar.add("item", {
  position = "popup." .. memory.name,
  icon = { drawing = false },
  label = {
    string = "0.0 GB / 16.0 GB",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 11.0,  -- Reduced from 14.0
    },
    color = colors.blue,
    align = "center",
    width = 160,  -- Wider for memory display
  },
})

local memory_proc1_item = sbar.add("item", {
  position = "popup." .. memory.name,
  icon = { drawing = false },
  label = {
    string = "Chrome: 2.1 GB",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 9.5,  -- Reduced from 11.0
    },
    color = colors.grey,
    align = "center",
    width = 180,  -- Increased for longer app names
  },
})

local memory_proc2_item = sbar.add("item", {
  position = "popup." .. memory.name,
  icon = { drawing = false },
  label = {
    string = "Safari: 1.5 GB",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 9.5,  -- Reduced from 11.0
    },
    color = colors.grey,
    align = "center",
    width = 180,  -- Increased for longer app names
  },
})

local memory_proc3_item = sbar.add("item", {
  position = "popup." .. memory.name,
  icon = { drawing = false },
  label = {
    string = "Finder: 0.8 GB",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 9.5,  -- Reduced from 11.0
    },
    color = colors.grey,
    align = "center",
    width = 180,  -- Increased for longer app names
  },
})

-- Function to update memory popup data
local function update_memory_popup_data()
  -- Get total memory statistics
  sbar.exec("vm_stat | head -10", function(vm_result)
    if not vm_result then return end

    local page_size = 16384

    local pages_free = tonumber(vm_result:match("Pages free:%s*(%d+)")) or 0
    local pages_active = tonumber(vm_result:match("Pages active:%s*(%d+)")) or 0
    local pages_inactive = tonumber(vm_result:match("Pages inactive:%s*(%d+)")) or 0
    local pages_wired = tonumber(vm_result:match("Pages wired down:%s*(%d+)")) or 0
    local pages_compressed = tonumber(vm_result:match("Pages occupied by compressor:%s*(%d+)")) or 0

    local used_pages = pages_active + pages_wired + pages_compressed
    local available_pages = pages_free + pages_inactive
    local total_pages = used_pages + available_pages

    local used_gb = (used_pages * page_size) / (1024 * 1024 * 1024)
    local total_gb = (total_pages * page_size) / (1024 * 1024 * 1024)
    local usage_pct = total_pages > 0 and (used_pages / total_pages * 100) or 0

    -- Color based on memory pressure
    local mem_color = colors.blue
    if usage_pct > 85 then
      mem_color = colors.red
    elseif usage_pct > 75 then
      mem_color = colors.orange
    elseif usage_pct > 60 then
      mem_color = colors.yellow
    end

    memory_usage_item:set({
      label = {
        string = string.format("%.1f GB / %.1f GB (%.0f%%)", used_gb, total_gb, usage_pct),
        color = mem_color
      }
    })

    -- Get top memory-consuming processes (RSS in KB) - use total_gb from closure
    local total_memory_gb = total_gb  -- Store for use in process loop
    sbar.exec("ps -eo pid,rss,comm | sort -nr -k2 | head -4", function(ps_result)
    if not ps_result then return end

    local ps_lines = {}
    for line in ps_result:gmatch("[^\n]+") do
      table.insert(ps_lines, line)
    end

    local procs = {
      {item = memory_proc1_item, default = "Chrome: 2.1 GB"},
      {item = memory_proc2_item, default = "Safari: 1.5 GB"},
      {item = memory_proc3_item, default = "Finder: 0.8 GB"}
    }

    -- Skip header line (first line is header: PID RSS COMMAND)
    for i, proc in ipairs(procs) do
      local line_idx = i + 1
      if ps_lines[line_idx] then
        local pid, rss_kb, command = ps_lines[line_idx]:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
        if rss_kb and command then
          local rss_gb = tonumber(rss_kb) / (1024 * 1024)

          -- Extract readable app name like Activity Monitor
          local name = command

          if name:match("/Applications/.*%.app/Contents/MacOS/") then
            local app_name = name:match("/Applications/([^/]+)%.app/")
            if app_name then
              name = app_name
            else
              name = name:match("/([^/]+)$") or name
            end
          elseif name:match("/Applications/.*%.app/") then
            name = name:match("/Applications/([^/]+)%.app/") or name
          elseif name:match("/System/.*Resources/") then
            name = name:match("/Resources/([^/]+)$") or name:match("/([^/]+)$") or name
          elseif name:match("/[^/]+$") then
            name = name:match("/([^/]+)$") or name
          end

          -- Clean up and limit length
          name = name:gsub("^%-", ""):sub(1, 15)  -- Increased from 9 to 15 for readability

          -- Calculate percentage of total memory
          local mem_pct = (rss_gb / total_memory_gb) * 100

          proc.item:set({
            label = {
              string = string.format("%s: %.1f GB (%.0f%%)", name, rss_gb, mem_pct)
            }
          })
        else
          proc.item:set({
            label = { string = proc.default }
          })
        end
      else
        proc.item:set({
          label = { string = proc.default }
        })
      end
    end
    end)
  end)
end

-- Memory Hover handlers with periodic refresh while open
local memory_popup_active = false

memory:subscribe("mouse.entered", function(env)
  memory_popup_active = true
  memory:set({ popup = { drawing = true } })
  -- Immediate update when popup opens
  update_memory_popup_data()
  -- Then start periodic refresh
  local function refresh()
    if not memory_popup_active then return end
    update_memory_popup_data()
    sbar.delay(3, refresh)
  end
  sbar.delay(3, refresh)  -- Start refresh after 3 seconds
end)

memory:subscribe("mouse.exited", function(env)
  memory_popup_active = false
  memory:set({ popup = { drawing = false } })
end)

-- Initial update via update manager
update_memory({})

-- Smart Activity Monitor Toggle
memory:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    -- Check if Activity Monitor is already open
    sbar.exec([[pgrep -f "Activity Monitor"]], function(result)
      if result and result:match("%d+") then
        -- Activity Monitor is open, close it
        sbar.exec([[osascript -e "tell application \"Activity Monitor\" to quit"]])
      else
        -- Activity Monitor is closed, open it
        sbar.exec([[open -a "Activity Monitor"]])
      end
    end)
  end
end)

-- Background around the memory item (graph only)
sbar.add("bracket", "widgets.memory.bracket", { memory.name }, {
  background = { color = colors.transparent, drawing = false }
})

-- Padding around the memory item
sbar.add("item", "widgets.memory.padding", {
  position = "right",
  width = settings.group_paddings
})

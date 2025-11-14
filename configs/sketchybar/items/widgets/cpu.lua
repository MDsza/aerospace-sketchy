local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local update_manager = require("helpers.update_manager")

-- CPU Total Load Graph (User + System) - Pure graph only, no labels
local cpu = sbar.add("graph", "widgets.cpu", 42, {
  position = "right",
  update_freq = 2,
  graph = {
    color = colors.blue,
    fill_color = colors.with_alpha(colors.blue, 0.3),  -- 30% fill visibility
    line_width = 2.0,
    height = 20          -- Compact height
  },
  background = {
    height = 24,         -- Reduced background
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = false,     -- No visible background
  },
  icon = {
    string = "□",
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

-- CPU display update function
local function update_cpu_display(load)
  -- Normalize 0..100% -> 0..1
  local normalized = math.min(math.max(load / 100.0, 0), 1.0)
  cpu:push({ normalized })

  -- Dynamic color intensity based on activity level
  local base_color = colors.blue
  if load > 80 then
    base_color = colors.red
  elseif load > 60 then
    base_color = colors.orange
  elseif load > 30 then
    base_color = colors.yellow
  end
  
  -- Calculate dynamic alpha: 0.3 (30%) at 0% load → 1.0 (100%) at 100% load
  local alpha = math.max(0.3, math.min(1.0, 0.3 + (load / 100.0) * 0.7))
  local dynamic_color = colors.with_alpha(base_color, alpha)

  cpu:set({
    graph = { color = dynamic_color },
    icon  = { color = dynamic_color }
  })
end

-- Optimized CPU update function using centralized system info
local function update_cpu(system_info)
  local load = system_info and system_info.cpu or nil
  
  if not load then
    -- Fallback to direct CPU query if batch info not available
    sbar.exec("/usr/bin/top -l 1 -n 0 | /usr/bin/grep 'CPU usage' | /usr/bin/awk '{gsub(/%/, \"\", $3); gsub(/%/, \"\", $5); user=$3; sys=$5; print user+sys}'", function(result)
      load = tonumber(result) or 0
      if load > 0 then
        update_cpu_display(load)
      end
    end)
    return
  end
  
  update_cpu_display(load)
end

-- Register with centralized update manager (for CPU graph only)
update_manager:register("cpu", update_cpu, "cpu")

-- CPU Popup Items
local cpu_usage_item = sbar.add("item", {
  position = "popup." .. cpu.name,
  icon = { drawing = false },
  label = {
    string = "0% CPU",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    color = colors.blue,  -- Blue like CPU icon
    align = "center",
    width = 140,

  },
})
local cpu_proc1_item = sbar.add("item", {
  position = "popup." .. cpu.name,
  icon = { drawing = false },
  label = {
    string = "Chrome: 15%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 11.0,  -- Smaller font
    },
    color = colors.grey,
    align = "center",
    width = 120,  -- Reduced width
  },
})

local cpu_proc2_item = sbar.add("item", {
  position = "popup." .. cpu.name,
  icon = { drawing = false },
  label = {
    string = "Finder: 8%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 11.0,  -- Smaller font
    },
    color = colors.grey,
    align = "center",
    width = 120,  -- Reduced width
  },
})

local cpu_proc3_item = sbar.add("item", {
  position = "popup." .. cpu.name,
  icon = { drawing = false },
  label = {
    string = "Safari: 3%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Regular"],
      size = 11.0,  -- Smaller font
    },
    color = colors.grey,
    align = "center",
    width = 120,  -- Reduced width
  },
})

-- Function to update CPU popup data
local function update_cpu_popup_data()
  -- Use Activity Monitor approach: ps with rate limiting to get realistic values
  sbar.exec("ps -eo pid,pcpu,command | grep -v ' 0.0 ' | sort -nr -k2 | head -4", function(ps_result)
    -- Also get overall CPU usage from top
    sbar.exec("top -l 1 -n 0 | grep 'CPU usage'", function(cpu_result)
      -- Extract CPU usage from top output  
      local cpu_usage = 0
      if cpu_result then
        local usage = cpu_result:match("CPU usage: ([%d%.]+)%%")
        cpu_usage = tonumber(usage) or 0
      end
      
      -- Update CPU usage with color
      local cpu_color = colors.blue
      if cpu_usage > 80 then
        cpu_color = colors.red
      elseif cpu_usage > 60 then
        cpu_color = colors.orange
      elseif cpu_usage > 30 then
        cpu_color = colors.yellow
      end
      
      cpu_usage_item:set({
        label = {
          string = string.format("%.0f%% CPU", cpu_usage),
          color = cpu_color
        }
      })
    end)
    
    -- Parse ps output for process data
    local ps_lines = {}
    if ps_result then
      for line in ps_result:gmatch("[^\n]+") do
        table.insert(ps_lines, line)
      end
    end
    
    -- Update process items
    local procs = {
      {item = cpu_proc1_item, default = "Chrome: 15%"},
      {item = cpu_proc2_item, default = "Finder: 8%"},
      {item = cpu_proc3_item, default = "Safari: 3%"}
    }
    
    -- Process the top 3 CPU processes (no header line with filtered ps command)
    for i, proc in ipairs(procs) do
      local line_idx = i  -- Direct indexing, no header to skip
      if ps_lines[line_idx] then
        -- Parse ps output: PID %CPU COMMAND
        local pid, cpu_pct, command = ps_lines[line_idx]:match("^%s*(%d+)%s+([%d%.]+)%s+(.+)$")
        if cpu_pct and command then
          -- Extract readable app name like Activity Monitor
          local name = command
          
          -- Handle different path patterns
          if name:match("/Applications/.*%.app/Contents/MacOS/") then
            -- /Applications/Warp.app/Contents/MacOS/stable -> Warp
            local app_name = name:match("/Applications/([^/]+)%.app/")
            if app_name then
              name = app_name
            else
              -- Fallback: get the executable name
              name = name:match("/([^/]+)$") or name
            end
          elseif name:match("/Applications/.*%.app/") then
            -- /Applications/ChatGPT.app/... -> ChatGPT
            name = name:match("/Applications/([^/]+)%.app/") or name
          elseif name:match("/System/.*Resources/") then
            -- /System/.../Resources/WindowServer -> WindowServer
            name = name:match("/Resources/([^/]+)$") or name:match("/([^/]+)$") or name
          elseif name:match("/[^/]+$") then
            -- Any other path: get the last component
            name = name:match("/([^/]+)$") or name
          end
          
          -- Clean up and limit length  
          name = name:gsub("^%-", ""):sub(1, 9)  -- 9 chars for better readability
          
          proc.item:set({
            label = {
              string = string.format("%s: %.1f%%", name, tonumber(cpu_pct) or 0)
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
end

-- CPU Hover handlers with periodic refresh while open
local cpu_popup_active = false

cpu:subscribe("mouse.entered", function(env)
  cpu_popup_active = true
  cpu:set({ popup = { drawing = true } })
  -- Immediate update when popup opens
  update_cpu_popup_data()
  -- Then start periodic refresh
  local function refresh()
    if not cpu_popup_active then return end
    update_cpu_popup_data()
    sbar.delay(3, refresh)
  end
  sbar.delay(3, refresh)  -- Start refresh after 3 seconds
end)

cpu:subscribe("mouse.exited", function(env)
  cpu_popup_active = false
  cpu:set({ popup = { drawing = false } })
end)

-- Initial update via update manager (for CPU graph)
update_cpu({})

-- Smart Activity Monitor Toggle
cpu:subscribe("mouse.clicked", function(env)
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

-- Background around the cpu item (graph only)
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { color = colors.transparent, drawing = false }
})

-- Padding around the cpu item
sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})
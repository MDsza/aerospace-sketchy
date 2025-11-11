local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local update_manager = require("helpers.update_manager")

-- System Status Widget - combines CPU temperature and disk space
local system_status = sbar.add("item", "widgets.system", {
  position = "right",
  icon = {
    string = icons.cpu,  -- Use proven CPU icon from icons.lua instead of problematic Unicode
    color = colors.with_alpha(colors.green, 0.5),  -- Start normal (green 50%), will be dynamic
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,  -- Same as volume/battery
    },
    y_offset = -6   -- Align with other widgets
  },
  label = { drawing = false },  -- Clean icon-only display
  popup = { 
    align = "right",   -- Right align to position correctly
    drawing = false,   -- Hidden by default, shown on hover
    y_offset = -12,    -- Optimized space from SketchyBar
    x_offset = -35,    -- Position between volume and battery
    background = {
      color = colors.black,  -- Black background for text readability
      corner_radius = 6,     -- Harmonized 6px corners
      shadow = { drawing = true },  -- Drop shadow for depth
      padding_left = 12,     -- Refined padding for better balance
      padding_right = 12,
      padding_top = 8,
      padding_bottom = 8,
      drawing = true
    }
  }
})

-- Popup items - clean layout without labels (just values)
local temp_item = sbar.add("item", {
  position = "popup." .. system_status.name,
  icon = { drawing = false },
  label = {
    string = "67°C",  -- Temperature with °C unit
    font = {
      family = settings.font.numbers,  -- Same as battery popup
      style = settings.font.style_map["Bold"],  -- Bold like battery percentage
      size = 14.0,  -- Same as battery popup
    },
    color = colors.white,  -- Will be updated dynamically
    align = "center",
    width = 60,  -- Wider for temperature values
  },
})

local disk_item = sbar.add("item", {
  position = "popup." .. system_status.name,
  icon = { drawing = false },
  label = {
    string = "45GB",  -- Free disk space
    font = {
      family = settings.font.numbers,  -- Same as battery popup
      style = settings.font.style_map["Bold"],  -- Bold like temperature for better visibility
      size = 12.0,  -- Same as battery time
    },
    color = colors.green,  -- Will be updated dynamically based on free space
    align = "center",
    width = 60,  -- Balanced width
  },
})

-- System status tracking
local current_cpu_temp = 0
local current_disk_free = 0

-- Function to get CPU temperature using macmon (from cpu_temp.lua)
local function get_cpu_temperature(callback)
  sbar.exec("python3 -c \"import subprocess, json; proc = subprocess.Popen(['macmon', 'pipe'], stdout=subprocess.PIPE, text=True); line = proc.stdout.readline(); proc.terminate(); data = json.loads(line) if line else {}; print(data.get('temp', {}).get('cpu_temp_avg', 0))\"", function(temp_output)
    local temp_celsius = tonumber(temp_output)
    
    if temp_celsius and temp_celsius > 0 and temp_celsius < 120 then
      callback(temp_celsius)
    else
      -- Fallback: use estimation based on CPU usage
      sbar.exec("/usr/bin/top -l 1 -n 0 | /usr/bin/grep 'CPU usage' | /usr/bin/awk '{gsub(/%/, \"\", $3); print $3}'", function(cpu_usage)
        local usage = tonumber(cpu_usage) or 5
        -- Conservative estimation
        local base_temp = 45  -- Realistic idle temperature
        local estimated_temp = base_temp + (usage * 0.6)
        estimated_temp = math.max(40, math.min(estimated_temp, 90))
        callback(estimated_temp)
      end)
    end
  end)
end

-- Function to get disk free space (simplified from disk.lua)
local function get_disk_free(callback)
  -- Helper to convert a numeric value + unit to decimal GB
  local function to_gb(num, unit)
    unit = (unit or ""):gsub("[^A-Za-z]", "")
    if unit == "GB" or unit == "G" then return num
    elseif unit == "GiB" or unit == "Gi" then return num * 1.073741824
    elseif unit == "TB" or unit == "T" then return num * 1000
    elseif unit == "TiB" or unit == "Ti" then return num * 1024
    elseif unit == "MB" or unit == "M" then return num / 1000
    elseif unit == "MiB" or unit == "Mi" then return num / 1024
    elseif unit == "KB" or unit == "K" then return num / 1000000
    elseif unit == "KiB" or unit == "Ki" then return num / 1048576
    else return num end
  end

  -- Try APFS container free space including purgeable
  local cmd = table.concat({
    "/usr/sbin/diskutil apfs list / | ",
    "/usr/bin/awk -F': *' '/Size \\(",
    "Capacity Ceiling\\)/{print \"TOTAL \" $2} ",
    "/Free Space \\(",
    "Purgeable \\+ Free\\)/{print \"FREE \" $2}'"
  })

  sbar.exec(cmd, function(apfs_out)
    local total_gb, free_gb
    for line in string.gmatch(apfs_out or "", "[^\n]+") do
      local tag, rest = line:match("^(%u+)%s+(.+)$")
      if tag and rest then
        local num, unit = rest:match("([%d%.]+)%s*([A-Za-z]+)")
        if num and unit then
          if tag == "TOTAL" then total_gb = to_gb(tonumber(num), unit) end
          if tag == "FREE"  then free_gb  = to_gb(tonumber(num), unit) end
        end
      end
    end

    if total_gb and free_gb then
      callback(free_gb)
    else
      -- Fallback to df -h if APFS parse failed
      sbar.exec("/bin/df -h / | /usr/bin/awk 'NR==2 {print $4}'", function(df_out)
        local fnum, funit = df_out:match("([%d%.]+)(%a+)")
        local free = to_gb(tonumber(fnum) or 30, funit)
        callback(free)
      end)
    end
  end)
end

-- Function to determine system status color and alpha
local function get_system_status(cpu_temp, disk_free)
  -- Critical: CPU > 85°C OR Disk < 10GB
  if cpu_temp > 85 or disk_free < 10 then
    return colors.red, 1.0  -- Full opacity for critical
  end
  
  -- Warning: CPU 70-85°C OR Disk 10-20GB  
  if (cpu_temp >= 70 and cpu_temp <= 85) or (disk_free >= 10 and disk_free <= 20) then
    return colors.orange, 0.7  -- More visible for warning
  end
  
  -- Normal: CPU < 70°C AND Disk > 20GB
  return colors.green, 0.5  -- Green with 50% alpha for normal operation
end

-- Function to update system status display
local function update_system_status()
  get_cpu_temperature(function(cpu_temp)
    get_disk_free(function(disk_free)
      -- Store current values
      current_cpu_temp = cpu_temp
      current_disk_free = disk_free
      
      -- Determine status color and alpha
      local status_color, status_alpha = get_system_status(cpu_temp, disk_free)
      
      -- Update main icon
      system_status:set({
        icon = {
          color = colors.with_alpha(status_color, status_alpha)
        }
      })
      
      -- Update popup items
      -- Temperature color logic (for popup)
      local temp_color = colors.green
      if cpu_temp > 85 then
        temp_color = colors.red
      elseif cpu_temp > 75 then
        temp_color = colors.orange  
      elseif cpu_temp > 65 then
        temp_color = colors.yellow
      end
      
      temp_item:set({
        label = {
          string = string.format("%.0f°C", cpu_temp),
          color = temp_color
        }
      })
      
      -- Disk color logic (for popup)
      local disk_color = colors.green  -- Default green for good values
      if disk_free < 20 then
        disk_color = colors.red     -- Critical: < 20GB
      elseif disk_free < 50 then
        disk_color = colors.orange  -- Warning: 20-50GB
      end
      -- Above 50GB stays green (like your 146GB!)
      
      disk_item:set({
        label = {
          string = string.format("%.0fGB", disk_free),
          color = disk_color  -- Dynamic color based on free space
        }
      })
    end)
  end)
end

-- Register with centralized update manager (temperature interval = 5s)
update_manager:register("system_status", function(system_info)
  update_system_status()
end, "temperature")

-- Initial update
update_system_status()

-- Hover functionality: show popup on mouse enter, hide on mouse exit (like battery/volume)
system_status:subscribe("mouse.entered", function(env)
  system_status:set({ popup = { drawing = true } })
  -- Refresh data when hovering for most current values
  update_system_status()
end)

system_status:subscribe("mouse.exited", function(env)
  system_status:set({ popup = { drawing = false } })
end)

-- Click handler: Open btop for system monitoring
system_status:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    sbar.exec("open -a Terminal && osascript -e 'tell application \"Terminal\" to do script \"btop\"'")
  end
end)

-- Bracket and padding (like other widgets)
sbar.add("bracket", "widgets.system.bracket", { system_status.name }, {
  background = { color = colors.transparent, drawing = false }
})

sbar.add("item", "widgets.system.padding", {
  position = "right",
  width = settings.group_paddings
})

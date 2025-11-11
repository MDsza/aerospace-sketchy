local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local update_manager = require("helpers.update_manager")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 19.0,
    },
    y_offset = -6   -- Move further down to bottom edge
  },
  label = { drawing = false },  -- No percentage label for clean icon-only display
  popup = { 
    align = "right",   -- Right align to position correctly
    drawing = false,  -- Hidden by default, shown on hover
    y_offset = -12,    -- Optimized space from SketchyBar
    x_offset = -20,    -- Move 20px away from screen edge to avoid collision
    background = {
      color = colors.black,  -- Black background for text readability
      corner_radius = 6,     -- Harmonized 6px corners as requested
      shadow = { drawing = true },  -- Drop shadow for depth
      padding_left = 12,     -- Refined padding for better balance
      padding_right = 12,
      padding_top = 8,
      padding_bottom = 8,
      drawing = true
    }
  }
})

-- Minimalist popup items - vertical layout: percentage, time, wattage (dynamic)
local percentage_item = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = { drawing = false },
  label = {
    string = "73%",
    font = {
      family = settings.font.numbers,  -- Same as spaces
      style = settings.font.style_map["Bold"],  -- Bold for emphasis like active spaces
      size = 14.0,  -- Same as active spaces
    },
    color = colors.white,  -- Will be updated dynamically to match battery icon color
    align = "center",
    width = 50,  -- Balanced width for centered short text
  },
})

local time_item = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = { drawing = false },
  label = {
    string = "...",  -- Default placeholder
    font = {
      family = settings.font.numbers,  -- Same as spaces
      style = settings.font.style_map["Regular"],  -- Regular like inactive spaces
      size = 12.0,  -- Same as inactive spaces
    },
    color = colors.grey,
    align = "center",
    width = 50,  -- Balanced width for centered short text
  },
})

local wattage_item = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = { drawing = false },
  label = {
    string = "65W",
    font = {
      family = settings.font.numbers,  -- Same as spaces
      style = settings.font.style_map["Regular"],
      size = 12.0,  -- Same as inactive spaces
    },
    color = colors.grey,
    align = "center",
    width = 50,  -- Balanced width for centered short text
  },
})


-- Optimized battery update function
local function update_battery()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon = "!"
    local label = "?"

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      -- No label text needed for clean display
    end

    local color = colors.green
    local charging, _, _ = batt_info:find("AC Power")
    
    -- Extract remaining time information with elegant placeholder
    local time_remaining = "..."
    local time_match = batt_info:match("(%d+:%d+) remaining")
    if time_match then
      time_remaining = time_match .. "h"
    elseif charging then
      local charge_time = batt_info:match("(%d+:%d+) until full")
      if charge_time then
        time_remaining = charge_time .. "h"
      else
        time_remaining = "..."
      end
    end

    -- Always show charge level visually, whether charging or not
    if found and charge > 80 then
      icon = icons.battery._100
    elseif found and charge > 60 then
      icon = icons.battery._75
    elseif found and charge > 40 then
      icon = icons.battery._50
    elseif found and charge > 20 then
      icon = icons.battery._25
      color = colors.orange
    else
      icon = icons.battery._0
      color = colors.red
    end
    
    -- Battery color logic with charging indicator
    if found then
      if charging then
        -- When charging: use a consistent bright color to indicate charging status
        -- while maintaining the visual charge level through the icon
        color = colors.blue  -- Bright blue indicates charging
      else
        -- Normal battery colors based on charge level
        if charge > 60 then
          color = colors.green
        elseif charge > 30 then
          color = colors.orange
        else
          color = colors.red
        end
      end
    end

    -- Update popup items with current data
    percentage_item:set({
      label = {
        string = charge and (charge .. "%") or "?%",
        color = color  -- Use same color as battery icon for harmony
      }
    })
    
    time_item:set({
      label = {
        string = time_remaining
      }
    })
    
    -- Show wattage only when charging, hide completely when on battery
    if charging then
      -- Estimate wattage when charging
      local wattage = "~65W"  -- Common for MacBook Pro
      wattage_item:set({
        label = {
          string = wattage
        },
        drawing = true  -- Show wattage line
      })
    else
      wattage_item:set({
        drawing = false  -- Hide wattage line completely when not charging
      })
    end
    
    -- Inverse transparency: 1.0 (100%) at 0% charge → 0.3 (30%) at 100% charge
    -- Je leerer die Batterie, desto sichtbarer (weniger transparent)
    local alpha = math.max(0.3, math.min(1.0, 1.0 - (charge / 100.0) * 0.7))
    
    battery:set({
      icon = {
        string = icon,
        color = colors.with_alpha(color, alpha)  -- Dynamic transparency: more visible when battery is low
      }
      -- No label set - clean icon-only display
    })
  end)
end

-- Register with centralized update manager (5 second interval for battery)
update_manager:register("battery", update_battery, "battery")

-- Keep event-based updates for immediate response
battery:subscribe({"power_source_change", "system_woke"}, update_battery)

-- Hover functionality: show popup on mouse enter, hide on mouse exit
battery:subscribe("mouse.entered", function(env)
  battery:set({ popup = { drawing = true } })
end)

battery:subscribe("mouse.exited", function(env)
  battery:set({ popup = { drawing = false } })
end)

-- Toggle Energy/Battery settings (works with German macOS) - smart open/close
battery:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    -- Check if System Settings/Preferences is already open
    sbar.exec([[pgrep -f "System Settings|System Preferences"]], function(result)
      if result and result:match("%d+") then
        -- Settings app is open, close it
        sbar.exec([[osascript -e "tell application \"System Settings\" to quit" || osascript -e "tell application \"System Preferences\" to quit"]])
      else
        -- Settings app is closed, open it
        sbar.exec([[open "x-apple.systempreferences:com.apple.preference.battery" || open /System/Library/PreferencePanes/Battery.prefpane || open /System/Library/PreferencePanes/EnergySaver.prefpane]])
      end
    end)
  end
end)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
  background = { color = colors.transparent, drawing = false }
})

sbar.add("item", "widgets.battery.padding", {
  position = "right",
  width = settings.group_paddings
})

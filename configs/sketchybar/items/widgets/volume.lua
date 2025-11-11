local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

-- Volume percentage removed for clean icon-only display

local volume_icon = sbar.add("item", "widgets.volume2", {
  position = "right",
  padding_right = -1,
  icon = {
    string = icons.volume._100,
    width = 0,
    align = "left",
    color = colors.with_alpha(colors.white, 0.3),  -- Start dimmed, will be dynamic
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    y_offset = -6   -- Move further down to bottom edge
  },
  label = {
    width = 25,
    align = "left",
    color = colors.with_alpha(colors.white, 0.3),  -- Start dimmed, will be dynamic
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    y_offset = -6   -- Move further down to bottom edge
  },
  popup = { 
    align = "right",   -- Right align to position correctly
    drawing = false,  -- Hidden by default, shown on hover
    y_offset = -12,    -- Optimized space from SketchyBar
    x_offset = -55,    -- Align right edge with battery popup (battery is narrower, so volume needs more offset)
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

-- Minimalist popup items - harmonized with battery design (centered, clean layout with SF-Icons)
local output_item = sbar.add("item", {
  position = "popup." .. volume_icon.name,
  icon = {
    string = "󰕾",  -- SF Symbol: speaker.wave.3.fill (original clean icon)
    font = {
      family = settings.font.numbers,  -- Same as spaces and battery
      style = settings.font.style_map["Regular"],
      size = 12.0,  -- Back to readable size for visible icons
    },
    color = colors.grey,
    padding_right = 6,  -- Space between icon and text
  },
  label = {
    string = "88% MacBook",  -- Percentage + device name like before
    font = {
      family = settings.font.numbers,  -- Same as battery popup
      style = settings.font.style_map["Bold"],  -- Bold like battery percentage
      size = 12.0,  -- Slightly smaller to fit device name
    },
    color = colors.white,  -- Will be updated dynamically to match volume icon color
    align = "center",  -- Centered like battery popup
    width = 110,   -- Wider to fit device name
  },
})

local input_item = sbar.add("item", {
  position = "popup." .. volume_icon.name,
  icon = {
    string = "󰍬",  -- SF Symbol: mic.fill (original clean icon)
    font = {
      family = settings.font.numbers,  -- Same as spaces
      style = settings.font.style_map["Regular"],
      size = 12.0,  -- Back to readable size for visible icons
    },
    color = colors.grey,
    padding_right = 6,  -- Space between icon and text
  },
  label = {
    string = "49% MacBook",  -- Percentage + device name like before
    font = {
      family = settings.font.numbers,  -- Same as battery popup
      style = settings.font.style_map["Regular"],  -- Regular like battery time
      size = 12.0,  -- Same as battery time
    },
    color = colors.grey,  -- Grey like battery time for hierarchy
    align = "center",  -- Centered like battery popup
    width = 110,   -- Wider to fit device name
  },
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
  volume_icon.name
}, {
  background = { color = colors.transparent, drawing = false },
  popup = { align = "center" }
})

sbar.add("item", "widgets.volume.padding", {
  position = "right",
  width = settings.group_paddings
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_bracket.name,
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob= {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.transparent, drawing = false, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

-- Function to truncate device names to first 8 characters
local function truncate_device_name(device_name)
  -- Remove common suffixes and clean up
  device_name = device_name:gsub("-Lautsprecher", "")
  device_name = device_name:gsub("-Mikrofon", "")
  device_name = device_name:gsub(" Speakers", "")
  device_name = device_name:gsub(" Microphone", "")
  
  -- Truncate to first 8 characters if longer
  if #device_name > 8 then
    return device_name:sub(1, 8)
  else
    return device_name
  end
end

-- Function to update audio popup with current device info
local function update_audio_popup(volume, volume_color)
  -- Get output device info
  sbar.exec("SwitchAudioSource -t output -c", function(output_device)
    output_device = output_device:gsub("\n", "")
    local short_output_device = truncate_device_name(output_device)
    
    -- Get input device info
    sbar.exec("SwitchAudioSource -t input -c", function(input_device)
      input_device = input_device:gsub("\n", "")
      local short_input_device = truncate_device_name(input_device)
      
      -- Get input volume (microphone level)
      sbar.exec("osascript -e 'input volume of (get volume settings)'", function(input_volume_str)
        local input_volume = tonumber(input_volume_str) or 0
        
        -- Update output item (speaker) - FIX: Always check current volume for red color
        local output_color = (volume == 0) and colors.red or (volume_color or colors.white)
        output_item:set({
          label = {
            string = volume .. "% " .. short_output_device,  -- Percentage + device name
            color = output_color  -- Use same color logic as battery for harmony
          }
        })
        
        -- Update input item (microphone) - with device name
        local input_color = (input_volume == 0) and colors.red or colors.grey
        input_item:set({
          label = {
            string = input_volume .. "% " .. short_input_device,  -- Percentage + device name
            color = input_color
          }
        })
      end)
    end)
  end)
end

volume_icon:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  -- Special handling for muted state (volume = 0)
  local icon_color, alpha
  if volume == 0 then
    -- Muted: Red and fully opaque for maximum visibility
    icon_color = colors.red
    alpha = 1.0  -- Full opacity for muted warning
  else
    -- Dynamic transparency: 0.3 (30%) at low volume → 1.0 (100%) at high volume
    -- Je lauter, desto weniger transparent (weißer)
    alpha = math.max(0.3, math.min(1.0, 0.3 + (volume / 100.0) * 0.7))
    icon_color = colors.white
  end
  
  volume_icon:set({ 
    label = { string = icon, color = colors.with_alpha(icon_color, alpha) },  -- Red when muted, white with dynamic transparency otherwise
    icon = { color = colors.with_alpha(icon_color, alpha) }  -- Red when muted, white with dynamic transparency otherwise
  })
  -- No percentage label - clean icon-only display
  volume_slider:set({ slider = { percentage = volume } })
  
  -- Update popup with current audio device information
  update_audio_popup(volume, icon_color)
end)

local function volume_collapse_details()
  local drawing = volume_bracket:query().popup.drawing == "on"
  if not drawing then return end
  volume_bracket:set({ popup = { drawing = false } })
  sbar.remove('/volume.device\\.*/')
end

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume_bracket:query().popup.drawing == "off"
  if should_draw then
    volume_bracket:set({ popup = { drawing = true } })
    sbar.exec("SwitchAudioSource -t output -c", function(result)
      current_audio_device = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output", function(available)
        current = current_audio_device
        local color = colors.grey
        local counter = 0

        for device in string.gmatch(available, '[^\r\n]+') do
          local color = colors.grey
          if current == device then
            color = colors.white
          end
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume_bracket.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = color },
            click_script = 'SwitchAudioSource -s "' .. device .. '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.grey .. ' --set $NAME label.color=' .. colors.white

          })
          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then delta = delta * 10.0 end

  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

-- Hover functionality: show popup on mouse enter, hide on mouse exit (like battery widget)
volume_icon:subscribe("mouse.entered", function(env)
  volume_icon:set({ popup = { drawing = true } })
  -- Update popup data when hovering - FIX: Determine correct color based on volume
  sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol_str)
    local current_volume = tonumber(vol_str) or 50
    local hover_color = (current_volume == 0) and colors.red or colors.white
    update_audio_popup(current_volume, hover_color)
  end)
end)

volume_icon:subscribe("mouse.exited", function(env)
  volume_icon:set({ popup = { drawing = false } })
end)

-- Toggle Sound settings (works with German macOS) - smart open/close
volume_icon:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    -- Check if System Settings/Preferences is already open
    sbar.exec([[pgrep -f "System Settings|System Preferences"]], function(result)
      if result and result:match("%d+") then
        -- Settings app is open, close it
        sbar.exec([[osascript -e "tell application \"System Settings\" to quit" || osascript -e "tell application \"System Preferences\" to quit"]])
      else
        -- Settings app is closed, open it
        sbar.exec([[open "x-apple.systempreferences:com.apple.preference.sound" || open /System/Library/PreferencePanes/Sound.prefpane]])
      end
    end)
  end
end)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
-- Volume percentage subscriptions removed


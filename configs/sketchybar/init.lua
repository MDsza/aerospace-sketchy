-- Require the sketchybar module
sbar = require("sketchybar")

-- Set the bar name, if you are using another bar instance than sketchybar
-- sbar.set_bar_name("bottom_bar")

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()

-- Add custom events (must be before items)
sbar.add("event", "claude_waiting_status")
sbar.add("event", "aerospace_workspace_change")

require("bar")
require("default")

-- Initialize performance optimization systems before loading items
local update_manager = require("helpers.update_manager")
local aerospace_batch = require("helpers.aerospace_batch")

-- Start centralized update and batch systems
update_manager:init()
aerospace_batch:init()

print("SketchyBar: Performance optimizations initialized (Aerospace)")

require("items")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()

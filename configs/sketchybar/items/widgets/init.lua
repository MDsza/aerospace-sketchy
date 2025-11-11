require("items.widgets.claude_notifier")  -- Claude Code notification widget (FIRST - highest priority visibility)
require("items.widgets.battery")
require("items.widgets.myping_toggle")  -- MyPing skill toggle (between battery and volume)
-- require("items.widgets.ipad") -- TEMPORARILY DISABLED
require("items.widgets.volume")
require("items.widgets.system_status")  -- NEW: Combined CPU temp + disk space
-- require("items.widgets.cpu_temp")   -- Replaced by system_status for temperature
require("items.widgets.cpu")          -- CPU load graph - positioned left of system_status
require("items.widgets.disk")         -- RESTORED: Disk IO (read/write) graphs and free indicator
require("items.widgets.memory")  -- Memory/RAM usage graph with dynamic colors
require("items.widgets.network")

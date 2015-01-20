--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 12.01.15
-- Time: 0:01
-- To change this template use File | Settings | File Templates.
--

local setmetatable = setmetatable
local lib=require("crzang.lib")
local cpu_widget = { mt = {} }
local indicator = require("crzang.widget.indicator")
local io = { lines = io.lines }
local math = { ceil = math.ceil }
local string = {
    format = string.format,
    gmatch = string.gmatch,
    len = string.len
}

local cpu = {
    last_total = 0,
    last_active = 0
}

local function get_cpu()
    local times = lib.helpers.first_line("/proc/stat")
    local at = 1
    local idle = 0
    local total = 0
    for field in string.gmatch(times, "[%s]+([^%s]+)")
    do
        -- 4 = idle, 5 = ioWait. Essentially, the CPUs have done
        -- nothing during these times.
        if at == 4 or at == 5
        then
            idle = idle + field
        end
        total = total + field
        at = at + 1
    end
    local active = total - idle

    -- Read current data and calculate relative values.
    local dactive = active - cpu.last_active
    local dtotal = total - cpu.last_total

    cpu_now = {}
    cpu_now.usage = math.ceil((dactive / dtotal) * 100)
    cpu_now.idle=idle
    cpu_now.total=total

    cpu.last_active = active
    cpu.last_total = total
    return cpu_now
end

local function new(image)
    local args = {
        max_value = function()
            return 100
        end,
        get_value = function()
            cpu_now = get_cpu()
            local used =cpu_now.usage
            return used
        end,
        icon = image,
        get_hint = function()
            cpu_now = get_cpu()
            local hint = "CPU \n" ..
                    "Total : " .. cpu_now.total .. "\n" ..
                    "Idle : " .. cpu_now.idle .. "\n" ..
                    "Usage : " .. cpu_now.usage .. "%\n"

            return hint
        end
    }
    return indicator(args)
end

function cpu_widget.mt:__call(...)
    return new(...)
end

return setmetatable(cpu_widget, cpu_widget.mt)
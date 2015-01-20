--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 12.01.15
-- Time: 0:01
-- To change this template use File | Settings | File Templates.
--

local setmetatable = setmetatable
local mem_widget = { mt = {} }
local indicator = require("crzang.widget.indicator")
local io = { lines = io.lines }
local math = { floor = math.floor }
local string = {
    format = string.format,
    gmatch = string.gmatch,
    len = string.len
}

local function get_mem()
    mem_now = {}
    for line in io.lines("/proc/meminfo")
    do
        for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+")
        do
            if k == "MemTotal" then mem_now.total = math.floor(v / 1024)
            elseif k == "MemFree" then mem_now.free = math.floor(v / 1024)
            elseif k == "Buffers" then mem_now.buf = math.floor(v / 1024)
            elseif k == "Cached" then mem_now.cache = math.floor(v / 1024)
            elseif k == "SwapTotal" then mem_now.swap = math.floor(v / 1024)
            elseif k == "SwapFree" then mem_now.swapf = math.floor(v / 1024)
            end
        end
    end
    return mem_now
end

local function new(image)
    local args = {
        max_value = function()
            mem_now = get_mem()
            return mem_now.total
        end,
        get_value = function()
            mem_now = get_mem()
            local used = mem_now.total - (mem_now.free + mem_now.buf + mem_now.cache)
            return used
        end,
        icon = image,
        get_hint = function()
            mem_now = get_mem()
            local hint = "Memory \n" ..
                    "Total : " .. mem_now.total .. " MB\n" ..
                    "Free : " .. mem_now.free .. " MB\n" ..
                    "Buffers : " .. mem_now.buf .. " MB\n" ..
                    "Cached : " .. mem_now.cache .. " MB\n" ..
                    "SwapTotal : " .. mem_now.swap .. " MB\n" ..
                    "SwapFree : " .. mem_now.swapf .. " MB"

            return hint
        end
    }
    return indicator(args)
end

function mem_widget.mt:__call(...)
    return new(...)
end

return setmetatable(mem_widget, mem_widget.mt)
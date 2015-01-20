--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 12.01.15
-- Time: 0:01
-- To change this template use File | Settings | File Templates.
--

local setmetatable = setmetatable
local fs_widget = { mt = {} }
local indicator = require("crzang.widget.indicator")
local io = { popen = io.popen }
local tonumber = tonumber
local pairs = pairs
local string = {
    match = string.match,
    format = string.format
}

local fs_widget = {
    mt = {}
}

-- Unit definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024 ^ 2 }

local function get_fs()
    --  helpers.set_map("fs", false)
    local partition = "/"

    fs_info = {}
    fs_now = {}

    local f = io.popen("LC_ALL=C df -kP " .. partition)

    for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
    local s = string.match(line, "^.-[%s]([%d]+)")
    local u, a, p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
    local m = string.match(line, "%%[%s]([%p%w]+)")

    if u and m then -- Handle 1st line and broken regexp
    fs_info[m .. " size_mb"] = string.format("%.1f", tonumber(s) / unit["mb"])
    fs_info[m .. " size_gb"] = string.format("%.1f", tonumber(s) / unit["gb"])
    fs_info[m .. " used_p"] = tonumber(p)
    fs_info[m .. " avail_p"] = 100 - tonumber(p)
    end
    end

    f:close()

    fs_now.used = tonumber(fs_info[partition .. " used_p"]) or 0
    fs_now.available = tonumber(fs_info[partition .. " avail_p"]) or 0
    fs_now.size_mb = tonumber(fs_info[partition .. " size_mb"]) or 0
    fs_now.size_gb = tonumber(fs_info[partition .. " size_gb"]) or 0


    return fs_now
end

local function new(image)
    local args = {
        max_value = function()
            return 100
        end,
        get_value = function()
            fs_now = get_fs()
            return fs_now.used
        end,
        icon = image,
        get_hint = function()
            fs_now = get_fs()
            local hint = "Root part \n" ..
                    "Size : " .. fs_now.size_gb .. "GB\n" ..
                    "Used : " .. fs_now.used .. "%\n"

            return hint
        end
    }
    return indicator(args)
end

function fs_widget.mt:__call(...)
    return new(...)
end

return setmetatable(fs_widget, fs_widget.mt)
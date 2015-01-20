--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 12.01.15
-- Time: 0:01
-- To change this template use File | Settings | File Templates.
--

local setmetatable = setmetatable
local first_line   = require("crzang.lib").helpers.first_line
local indicator = require("crzang.widget.indicator")
local io = {
    open = io.open,
    popen = io.popen
}

local tonumber = tonumber
local math         = { floor  = math.floor }

local wlan_widget = {
    mt={}
}

local function get_wlan()
    local wlan_now={

    }
    local link = 0
    local fd = io.open("/proc/net/wireless")
    local device= "wlan0"
    if not fd then return end

    for line in fd:lines() do
        if line:match("^ "..device) then
            link = tonumber(line:match("   (%d?%d?%d)"))
            break
        end
    end
    fd:close()

    fd = io.popen("iwconfig " .. device)
    if fd then
        local scale = 100
        for line in fd:lines() do
            if line:match("Link Quality=") then
                scale = tonumber(line:match("=%d+/(%d+)"))
            end
        end
        link = math.floor((link / scale) * 100)
    end
    wlan_now.link=link
    return wlan_now
end

local function new(image)
    local args = {
        max_value = function()
            return 100
        end,
        get_value = function()
            wlan_now = get_wlan()
            return wlan_now.link
        end,
        icon = image,
        get_hint = function()
            wlan_now = get_wlan()
            local hint = "WiFi state \n" ..
                    "Status : " .. wlan_now.link

            return hint
        end
    }
    return indicator(args)
end

function wlan_widget.mt:__call(...)
    return new(...)
end

return setmetatable(wlan_widget, wlan_widget.mt)
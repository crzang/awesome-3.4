--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 12.01.15
-- Time: 0:01
-- To change this template use File | Settings | File Templates.
--

local setmetatable = setmetatable
local first_line = require("crzang.lib").helpers.first_line
local temp_widget = { mt = {} }
local indicator = require("crzang.widget.indicator")
local io = {  open = io.open }
local tonumber     = tonumber


local temp = {
}

local function get_temp()
    temp_now={}
    local tempfile ="/sys/class/thermal/thermal_zone0/temp"
    local trip_tempfile = "/sys/class/thermal/thermal_zone0/trip_point_0_temp"
    local f = io.open(tempfile)
    if f ~= nil
    then
        temp_now.coretemp = tonumber(f:read("*a")) / 1000
        f:close()
    else
        temp_now.coretemp = 0
    end

    local max_f = io.open(trip_tempfile)
    if max_f ~= nil
    then
        temp_now.max = tonumber(max_f:read("*a")) / 1000
        max_f:close()
    else
        temp_now.max = 0
    end
    return temp_now
end

local function new(image)
    local args = {
        max_value = function()
            temp_now = get_temp()
            return temp_now.max
        end,
        get_value = function()
            temp_now = get_temp()
            return temp_now.coretemp
        end,
        icon = image,
        get_hint = function()
            temp_now = get_temp()
            local hint = "Temp \n" ..
                    "Max : " .. temp_now.max .. "\n" ..
                    "Current : " .. temp_now.coretemp .. "\n"

            return hint
        end
    }
    return indicator(args)
end

function temp_widget.mt:__call(...)
    return new(...)
end

return setmetatable(temp_widget, temp_widget.mt)
--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 12.01.15
-- Time: 0:01
-- To change this template use File | Settings | File Templates.
--

local setmetatable = setmetatable
local indicator = require("crzang.widget.indicator")
local pulseaudio = require("crzang.lib.pulseaudio")
local mixer = 'pavucontrol' -- mixer command
local wibox = require("wibox")
local awful = require("awful")
local step = 0.05
local p = pulseaudio:Create()
local io = {
    open = io.open,
    popen = io.popen
}

local tonumber = tonumber
local math = { floor = math.floor }

local pulse_widget = {
    mt = {},
    widget = wibox.layout.fixed.vertical()
}


function pulse_widget.Up()
    p:SetVolume(p.Volume + step)
end

function pulse_widget.Down()
    p:SetVolume(p.Volume - step)
end


function pulse_widget.ToggleMute()
    p:ToggleMute()
end

function pulse_widget.Update()
    p:UpdateState()
end

function pulse_widget.LaunchMixer()
    awful.util.spawn_with_shell(mixer)
end

local function new(image)
    pulse_widget.widget:buttons(awful.util.table.join(awful.button({}, 1, pulse_widget.ToggleMute),
        awful.button({}, 3, pulse_widget.LaunchMixer),
        awful.button({}, 4, pulse_widget.Up),
        awful.button({}, 5, pulse_widget.Down)))

    local args = {
        max_value = function()
            return 1
        end,
        get_value = function()
            if p.Mute then
                return -1
            else
                return p.Volume
            end
        end,
        icon = image,
        get_hint = function()
            local hint = "Volume state \n" ..
                    "Status : " .. p.Volume * 100

            return hint
        end
    }
    pulse_widget.widget:add(indicator(args))
    return pulse_widget.widget
end

function pulse_widget.mt:__call(...)
    return new(...)
end

return setmetatable(pulse_widget, pulse_widget.mt)
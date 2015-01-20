--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 11.01.15
-- Time: 23:48
-- To change this template use File | Settings | File Templates.
--

local newtimer = require("crzang.lib").helpers.newtimer
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local setmetatable = setmetatable
local beautiful = require("beautiful")
local gears = require("gears")
local io = io

local indicator = {
    mt = {}
}

local indicator_widget
local capi = {
    mouse = mouse,
    client = client
}

local hint = nil

local function hide_hint()
    if hint ~= nil then
        naughty.destroy(hint)
        hint.visible = false
    end
end

local function show_hint(hint_text)
    hint = naughty.notify({
        text = hint_text(),
        timeout = 0,
        screen = client.focus and client.focus.screen or 1
    })
end

local default_color = {
    type = "linear",
    from = { 0, 20 },
    to = { 0, 0 },
    stops =
    { { 0, "#00FF00" }, { 0.5, "#887700" }, { 1.0, "#FF0000" } }
    --{ { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1.0, "#FF5656" } }
}

local disabled_color = {
    type = "linear",
    from = { 0, 20 },
    to = { 0, 0 },
    stops =
    { { 0, "#FF0000" }, { 0.5, "#EE0000" }, { 1.0, "#DD0000" } }
}
local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 5
    local max_value = args.max_value or function() return 100 end
    local get_value = args.get_value or function() return 20 end
    local get_hint = args.get_hint or nil
    local icon = args.icon or ""

    local layout_widget = wibox.layout.fixed.vertical()
    --indicator_widget = layout_widget
    if icon then
        layout_widget:add(wibox.widget.imagebox(icon))
    end

    local widget = awful.widget.progressbar()
    indicator_widget = widget
    widget:set_vertical(true)

    widget:set_color(default_color)
    widget:set_max_value(max_value())
    function update()
        local value=get_value();
        if value==-1 then
            widget:set_color(disabled_color)
        else
            widget:set_color(default_color)
        end
        widget:set_value(value)
    end

    newtimer("", timeout, update)

    if get_hint() ~= nil then
        widget:connect_signal("mouse::enter", function() show_hint(get_hint) end)
        widget:connect_signal("mouse::leave", function() hide_hint() end)
    end

    layout_widget:add(widget)
    return layout_widget
end

function indicator.mt:__call(...)
    return worker(...)
end

return setmetatable(indicator, indicator.mt)

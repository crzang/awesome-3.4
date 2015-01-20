--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 16.01.15
-- Time: 23:03
-- To change this template use File | Settings | File Templates.
--


local pulseaudio = {}


local cmd = "pacmd"
local default_sink = ""

function pulseaudio:Create()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.Volume = 0     -- volume of default sink
    o.Mute = false   -- state of the mute flag of the default sink

    -- retreive current state from Pulseaudio
    pulseaudio.UpdateState(o)

    return o
end

function pulseaudio:UpdateState()
    local f = io.popen(cmd .. " dump")

    -- if the cmd can't be found
    if f == nil then
        return false
    end

    local out = f:read("*a")

    -- get the default sink
    default_sink = string.match(out, "set%-default%-sink ([^\n]+)")

    if default_sink == nil then
        default_sink = ""
        return false
    end

    -- retreive volume of default sink
    for sink, value in string.gmatch(out, "set%-sink%-volume ([^%s]+) (0x%x+)") do
        if sink == default_sink then
            self.Volume = tonumber(value) / 0x10000
        end
    end

    -- retreive mute state of default sink
    local m
    for sink, value in string.gmatch(out, "set%-sink%-mute ([^%s]+) (%a+)") do
        if sink == default_sink then
            m = value
        end
    end

    self.Mute = m == "yes"

    f:close()
end

-- Run process and wait for it to end
function run(cmd)
    io.popen(cmd):read("*a")
end

-- Sets the volume of the default sink to vol from 0 to 1.
function pulseaudio:SetVolume(vol)
    if vol > 1 then
        vol = 1
    end

    if vol < 0 then
        vol = 0
    end

    vol = vol * 0x10000
    -- set…
    run(cmd .. " set-sink-volume " .. default_sink .. " " .. string.format("0x%x", vol))

    -- …and update values
    self:UpdateState()
end


-- Toggles the mute flag of the default default_sink.
function pulseaudio:ToggleMute()
    if self.Mute then
        run(cmd .. " set-sink-mute " .. default_sink .. " 0")
    else
        run(cmd .. " set-sink-mute " .. default_sink .. " 1")
    end

    -- …and update values.
    self:UpdateState()
end


return pulseaudio


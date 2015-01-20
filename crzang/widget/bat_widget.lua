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
local io           = { popen  = io.popen }

local math         = { floor  = math.floor }
local string       = { format = string.format }

local bat_widget = {
    mt={}
}

-- Unit definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

local function get_bat()
    local battery ="BAT1"

    bat_now = {
        status = "Not present",
        perc   = "N/A",
        time   = "N/A",
        watt   = "N/A"
    }

    local bstr  = "/sys/class/power_supply/" .. battery

    local present = first_line(bstr .. "/present")

    if present == "1"
    then
        local rate  = first_line(bstr .. "/power_now") or
                first_line(bstr .. "/current_now")

        local ratev = first_line(bstr .. "/voltage_now")

        local rem   = first_line(bstr .. "/energy_now") or
                first_line(bstr .. "/charge_now")

        local tot   = first_line(bstr .. "/energy_full") or
                first_line(bstr .. "/charge_full")

        bat_now.status = first_line(bstr .. "/status") or "N/A"

        rate  = tonumber(rate) or 1
        ratev = tonumber(ratev)
        rem   = tonumber(rem)
        tot   = tonumber(tot)

        local time_rat = 0
        if bat_now.status == "Charging"
        then
            time_rat = (tot - rem) / rate
        elseif bat_now.status == "Discharging"
        then
            time_rat = rem / rate
        end

        local hrs = math.floor(time_rat)
        if hrs < 0 then hrs = 0 elseif hrs > 23 then hrs = 23 end

        local min = math.floor((time_rat - hrs) * 60)
        if min < 0 then min = 0 elseif min > 59 then min = 59 end

        bat_now.time = string.format("%02d:%02d", hrs, min)

        bat_now.perc = first_line(bstr .. "/capacity")

        if not bat_now.perc then
            local perc = (rem / tot) * 100
            if perc <= 100 then
                bat_now.perc = string.format("%d", perc)
            elseif perc > 100 then
                bat_now.perc = "100"
            elseif perc < 0 then
                bat_now.perc = "0"
            end
        end

        if rate ~= nil and ratev ~= nil then
            bat_now.watt = string.format("%.2fW", (rate * ratev) / 1e12)
        else
            bat_now.watt = "N/A"
        end

    end

    return bat_now
end

local function new(image)
    local args = {
        max_value = function()
            return 100
        end,
        get_value = function()
            bat_now = get_bat()
            return bat_now.perc
        end,
        icon = image,
        get_hint = function()
            bat_now = get_bat()
            local hint = "Battary \n" ..
                    "Status : " .. bat_now.status .. "\n" ..
                    "Perc : " .. bat_now.perc .. "%\n"

            return hint
        end
    }
    return indicator(args)
end

function bat_widget.mt:__call(...)
    return new(...)
end

return setmetatable(bat_widget, bat_widget.mt)
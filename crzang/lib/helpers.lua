--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 20.01.15
-- Time: 0:47
-- To change this template use File | Settings | File Templates.
--

local capi   = { timer = timer }
local io     = { open = io.open,
    lines = io.lines }

local helpers = {}

-- {{{ Escape a string
function helpers.escape(text)
    local xml_entities = {
        ["\""] = "&quot;",
        ["&"]  = "&amp;",
        ["'"]  = "&apos;",
        ["<"]  = "&lt;",
        [">"]  = "&gt;"
    }

    return text and text:gsub("[\"&'<>]", xml_entities)
end
-- }}}

-- {{{ Timer maker
local timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart)
    timer_table[name] = capi.timer({ timeout = timeout })
    timer_table[name]:connect_signal("timeout", fun)
    timer_table[name]:start()
    if not nostart then
        timer_table[name]:emit_signal("timeout")
    end
end

-- {{{ File operations

-- see if the file exists and is readable
function helpers.file_exists(file)
    local f = io.open(file)
    if f then
        local s = f:read()
        f:close()
        f = s
    end
    return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function helpers.lines_from(file)
    if not helpers.file_exists(file) then return {} end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

-- get first line of a file, return nil if
-- the file does not exist
function helpers.first_line(file)
    return helpers.lines_from(file)[1]
end

-- get first non empty line from a file,
-- returns nil otherwise
function helpers.first_nonempty_line(file)
    for k,v in pairs(helpers.lines_from(file)) do
        if #v then return v end
    end
    return nil
end

-- }}}
return helpers
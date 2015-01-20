--[[
                                             
     Powerarrow Darker Awesome WM config 2.0 
     github.com/copycat-killer               
                                             
--]]

-- {{{ Required libraries
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local common = require("awful.widget.common")
local crzang = require("crzang")
-- }}}

-- add\setup popup run
require("crzang.widget.popup_run")
crzang.widget.popup_run.set_opacity(0.7)
crzang.widget.popup_run.set_prompt_string("$> ")
crzang.widget.popup_run.set_width(0.5)
crzang.widget.popup_run.set_height(18)
crzang.widget.popup_run.set_border_width(1)


-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = err
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

--run_once("google-chrome")
--run_once("skype")
--run_once("~/runidea")
-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

-- common
modkey = "Mod4"
altkey = "Mod1"
terminal = "terminator"
editor = os.getenv("EDITOR") or "nano" or "vi"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser = "google-chrome"
idea = "runidea"
gui_editor = "gvim"
graphics = "gimp"
mail = terminal .. " -e mutt "
iptraf = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr = terminal .. " -g 130x34-320+16 -e ncmpcpp "

local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
}
-- }}}

-- {{{ Tags
tags = {
    names = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
    layout = {
        layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],
        layouts[1], layouts[1], layouts[1], layouts[2]
    }
}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Menu
require("freedesktop/freedesktop")
-- }}}

-- {{{ Wibox

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock("%a\n%d\n%m\n%H\n%M")
mytextclock:set_font("Terminus 7")
-- calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 8 })

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", "" }, { "ru", "" } }
kbdcfg.current = 1 -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][1] .. " ")
kbdcfg.switch = function()
    kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
    local t = kbdcfg.layout[kbdcfg.current]
    kbdcfg.widget:set_text(" " .. t[1] .. " ")
    os.execute(kbdcfg.cmd .. " " .. t[1] .. " " .. t[2])
end

-- Mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(awful.button({}, 1, function() kbdcfg.switch() end)))

-- Mail IMAP check-- commented because it needs to be set before use
mailwidget = crzang.widget.gmail_widget(beautiful.widget_mail)

-- MEM
memwidget = crzang.widget.mem_widget(beautiful.widget_mem)

-- CPU
cpuwidget = crzang.widget.cpu_widget(beautiful.widget_cpu)

-- Coretemp
tempwidget = crzang.widget.temp_widget(beautiful.widget_temp)

-- / fs
fswidget = crzang.widget.fs_widget(beautiful.widget_hdd)

-- Battery
batwidget = crzang.widget.bat_widget(beautiful.widget_battery)

-- Net
netwidget = crzang.widget.wlan_widget(beautiful.widget_net)

--PulseAudio
pulsewidget = crzang.widget.pulse_widget()

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl_v)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl_v)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld_v)

-- Create a wibox for each screen and add it
mywibox = {}
mywibox2 = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(awful.button({}, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({}, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end),
    awful.button({}, 3, function()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ width = 250 })
        end
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
        awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all,
        mytaglist.buttons, nil, common.list_update, wibox.layout.fixed.vertical())

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons, nil, common.list_update, wibox.layout.fixed.vertical())

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "left", screen = s, width = 18 })

    mywibox2[s] = awful.wibox({ position = "right", screen = s, width = 20 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.vertical()
    left_layout:add(spr)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(spr)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.vertical()
    if s == 1 then
        systray = wibox.widget.systray()
        right_layout:add(systray)
    end
    right_layout:add(spr)
    right_layout:add(arrl)
    right_layout:add(pulsewidget)
    right_layout:add(arrl_ld)
    right_layout:add(mailwidget)
    right_layout:add(arrl_dl)
    right_layout:add(memwidget)
    right_layout:add(arrl_ld)
    right_layout:add(cpuwidget)
    right_layout:add(arrl_dl)
    right_layout:add(tempwidget)
    right_layout:add(arrl_ld)
    right_layout:add(fswidget)
    right_layout:add(arrl_dl)
    right_layout:add(batwidget)
    right_layout:add(arrl_ld)
    right_layout:add(netwidget)
    right_layout:add(arrl_dl)
    right_layout:add(mytextclock)
    right_layout:add(spr)
    right_layout:add(arrl_ld)


    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.vertical()
    layout:set_top(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_bottom(mylayoutbox[s])
    mywibox[s]:set_widget(layout)

    mywibox2[s]:set_widget(right_layout)
end
-- }}}

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(-- Take a screenshot
-- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left", awful.tag.viewprev),
    awful.key({ modkey }, "Right", awful.tag.viewnext),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),


    -- Default client focus
    awful.key({ altkey }, "k",
        function()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mywibox2[mouse.screen].visible = not mywibox2[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift" }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ altkey, "Shift" }, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1) end),
    awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey, }, "z", function() drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey, }, "c", function() lain.widgets.calendar:show(7) end),
    awful.key({ altkey, }, "h", function() fswidget.show(7) end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function() os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function() awful.util.spawn(browser) end),
    awful.key({ modkey }, "i", function() awful.util.spawn(idea) end),
    awful.key({ modkey }, "s", function() awful.util.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function() awful.util.spawn(graphics) end),

    -- Prompt
    awful.key({ modkey }, "r", crzang.widget.popup_run.run_prompt),
    awful.key({ modkey }, "x",
        function()
            awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox[mouse.screen].widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
        end),
    awful.key({}, "XF86AudioRaiseVolume", crzang.widget.pulse_widget.Up),
    awful.key({}, "XF86AudioLowerVolume", crzang.widget.pulse_widget.Down),
    awful.key({}, "XF86AudioMute", crzang.widget.pulse_widget.ToggleMute),
    awful.key({ "Mod1" }, "Shift_L", function() kbdcfg.switch() end))

clientkeys = awful.util.table.join(awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, }, "o", awful.client.movetoscreen),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewonly(tag)
                end
            end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.movetotag(tag)
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.toggletag(tag)
                end
            end))
end

clientbuttons = awful.util.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            keys = clientkeys,
            buttons = clientbuttons,
            size_hints_honor = false
        }
    },
    {
        rule = { class = "terminator" },
        properties = { opacity = 0.6 }
    },

    {
        rule = { class = "MPlayer" },
        properties = { floating = true }
    },

    {
        rule = { class = "Dwb" },
        properties = { tag = tags[1][1] }
    },

    {
        rule = { class = "skype" },
        properties = { tag = tags[1][9] }
    },

    --    { rule = { class = "idea" },
    --        properties = { tag = tags[1][1] } },

    {
        rule = { class = "google-chrome" },
        properties = { tag = tags[1][1] }
    },

    {
        rule = { class = "Gimp" },
        properties = { tag = tags[1][4] }
    },

    {
        rule = { class = "Gimp", role = "gimp-image-window" },
        properties = {
            maximized_horizontal = true,
            maximized_vertical = true
        }
    },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
    -- enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup and not c.size_hints.user_position
            and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
            awful.button({}, 3, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
            end))

        -- widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- the title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c, { size = 16 }):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    if #clients > 0 then -- Fine grained borders and floaters control
    for _, c in pairs(clients) do -- Floaters always have borders
    if awful.client.floating.get(c) or layout == "floating" then
        c.border_width = beautiful.border_width

        -- No borders with only one visible client
    elseif #clients == 1 or layout == "max" then
        clients[1].border_width = 0
    else
        c.border_width = beautiful.border_width
    end
    end
    end
end)
end
-- }}}

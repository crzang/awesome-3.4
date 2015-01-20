--
-- Created by IntelliJ IDEA.
-- User: crzang
-- Date: 17.01.15
-- Time: 0:03
-- To change this template use File | Settings | File Templates.
--
local setmetatable = setmetatable
local wibox = require("wibox")
local lib=require("crzang.lib")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gmail_widget = {
	mt={}
}

local lib_gmail=lib.lib_gmail
-- }}}
local hint = nil

local function hide_hint()
	if hint ~= nil then
		--naughty.destroy(hint)
		hint.visible = false
	end
end

local function show_hint(show_diff)
	local hint_box = wibox.widget.textbox()
	
	hint= wibox({
			fg = beautiful.fg_normal,
			bg = beautiful.bg_normal,
			border_color = beautiful.bg_focus,
		})
	hint.opacity = 0.7
	hint.visible = true
	hint.screen = s
	hint.ontop = true	
	local cur_mail=lib_gmail.get_cache()
	local subjects=""
	local fromtable=cur_mail.subject
	local header_text="Mail \n Unread :" ..cur_mail.count .."\n"
	local hint_height=30
	if show_diff then
		fromtable=cur_mail.diff
		header_text="<span color='red' font='Terminus 18'>New mail count:"..table.getn(fromtable).."\n</span>"
		hint_height=45
	end
	
	for i,entry in ipairs(fromtable) do	
		local text_entry="<span color='yellow'>"..lib.helpers.escape(entry
		.author.name)..
		"</span> \t\"<span color='green'>"..lib.helpers.escape(entry.title)
		.. "</span>\"\n"
		subjects=subjects .. text_entry
		hint_height=hint_height+15
	end
	local s=client.focus and client.focus.screen or 1
	hint:geometry({
			width = screen[s].geometry.width/2,
			height = hint_height,
			y=20,
			x = screen[s].geometry.width/2-50
		})
	
	
	local hint_text="<span color='white'>"..header_text .. subjects .."</span>"
	hint_box:set_ellipsize(true)
	hint_box:set_markup(hint_text)
	-- Widgets for prompt wibox
	hint:set_widget(hint_box)
	hint:connect_signal("mouse::leave", function() hint.visible=false end)
	
end

local function show_mails(mails)
end

local function new(image)
	local timeout = 5
	local widget=wibox.widget.textbox("G")

	local function update()
		local cur_mail=lib_gmail.get_mail()
		if cur_mail.changed and next(cur_mail.diff)~=nil then
			show_hint(true)
		end
		widget:set_text(cur_mail.count)
	end
	widget:connect_signal("mouse::enter", function() show_hint(false) end)
	widget:connect_signal("mouse::leave", function() hide_hint() end)
	lib.helpers.newtimer("", timeout, update)
	return widget
end

function gmail_widget.mt:__call(...)
	return new(...)
end

return setmetatable(gmail_widget, gmail_widget.mt)



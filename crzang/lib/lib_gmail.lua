require 'pl'
local setmetatable = setmetatable
local io = { popen = io.popen }
local string = {
    find = string.find,
    match = string.match
}

local lib_gmail = {}
-- {{{ Variable definitions
local rss = {
    inbox = {
        "https://mail.google.com/mail/feed/atom",
        "Gmail %- Inbox"
    },
    unread = {
        "https://mail.google.com/mail/feed/atom/unread",
        "Gmail %- Label"
    },
    --labelname = {
    --  "https://mail.google.com/mail/feed/atom/labelname",
    --  "Gmail %- Label"
    --},
}
-- }}}
-- Default is just Inbox
local feed = rss.inbox
local mail = {
    count = 0,
    subject = {}
}


local function is_text(s) return type(s) == 'string' end

function get_text(doc)
    local res = {}
    for i, el in ipairs(doc) do
        if is_text(el) then table.insert(res, el) end
    end
    return table.concat(res);
end

local function make_diff(mail, old_subject)
    mail.diff = {}
    for i, entry in ipairs(mail.subject) do
        local exist = false
        for j, old_entry in ipairs(old_subject) do
            if old_entry.id == entry.id then
                exist = true
            end
        end
        if not exist then
            table.insert(mail.diff, entry)
        end
    end
end

-- {{{ Gmail widget type
local function worker()
    -- Get info from the Gmail atom feed
    local f = io.popen("curl --connect-timeout 1 -m 3 -fsn " .. feed[1])

    -- Could be huge don't read it all at once, info we are after is at the top
    for line in f:lines() do

        -- Find subject tags
        local title = string.match(line, "<title>(.*)</title>")
        local data = xml.parse(line)
        if data ~= nil then
            local old_subject = mail.subject
            mail.subject = {}
            for item in data:childtags() do
                if item.tag == "fullcount" then
                    local last_count = mail.count
                    mail.count = get_text(item)
                    if mail.count ~= last_count then
                        mail.changed = true
                    else
                        mail.changed = false
                    end
                else if item.tag == "entry" then
                    local entry = {}

                    for sub_item in item:childtags() do
                        local text = get_text(sub_item)

                        if sub_item.tag == "title" then
                            entry.title = text
                        elseif sub_item.tag == "id" then
                            entry.id = text
                        elseif sub_item.tag == "summary" then
                            entry.summary = text
                        elseif sub_item.tag == "link" then
                            entry.link = sub_item.attr.href
                        elseif sub_item.tag == "name" then
                            entry.name = text
                        elseif sub_item.tag == "author" then
                            local author = {}
                            for t in sub_item:childtags() do
                                local t_text = get_text(t)
                                if t.tag == "name" then
                                    author.name = t_text
                                elseif t.tag == "email" then
                                    author.email = t_text
                                end
                            end
                            entry.author = author
                        end
                    end
                    pretty.dump(entry)
                    table.insert(mail.subject, entry)
                end
                end
                make_diff(mail, old_subject)
            end
        end
    end
    f:close()

    return mail
end

-- }}}

function lib_gmail.get_mail()
    return worker()
end

function lib_gmail.get_cache()
    return mail
end

worker()
return lib_gmail
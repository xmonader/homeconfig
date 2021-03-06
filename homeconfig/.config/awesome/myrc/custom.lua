local keydoc = require("keydoc")
local awful = require("awful")
local client = client
local awesome = awesome
local keygrabber = keygrabber
local screen = screen
local mouse = mouse
local naughty = require("naughty")
local ipairs = ipairs
local string = string
local os = os
local io = io
local widgets = require("myrc.widgets")
local runonce = require("myrc.runonce")
local myrc = {}
local lockreplaceid = nil
myrc.util = require("myrc.util")

module("myrc.custom")

browser = "browser"
terminal = "urxvtc"
autostart = true
winkey = "Mod4"
altkey = "Mod1"
capskey = "Mod4"
VGA = screen.count()
LCD = 1

runonce.run("dex -as ~/.config/autostart")

function removeFile(file)
    local f = io.open(file,"r")
    if f then
        os.remove(file)
        f:close()
    end
end

tags = {
    {
        name        = "1:Term",                 -- Call the tag "Term"
        key         = "1",
        init        = true,                   -- Load the tag on startup
        launch      = "urxvt",
        max_clients = 4,
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {VGA},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        class       = {"xterm" , "urxvt" , "aterm","URxvt","XTerm","konsole","terminator","gnome-terminal"}
    },
    {
        name        = "2:IM",                 -- Call the tag "Term"
        key         = "2",
        launch      = "pidgin",
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        init        = false,                   -- Load the tag on startup
        screen      = {VGA},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.fair.horizontal, -- Use the tile layout
        class       = {"Pidgin", "Skype", "gajim", 'Telegram'}
    },
    {
        name        = "3:Web",                 -- Call the tag "Term"
        key         = "3",
        launch      = "browser",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {LCD},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.max, -- Use the tile layout
        class       = {"Chrome", "Google-chrome-stable", "Chromium", "Midori", "Navigator", "Namoroka","Firefox"}
    },
    {
        name        = "4:Mail",                 -- Call the tag "Term"
        key         = "4",
        launch      = "emailclient",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {LCD},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        class       = {"Thunderbird", "Mail", "Msgcompose", "Evolution"}
    },
    {
        name        = "5:FS",                 -- Call the tag "Term"
        key         = "5",
        launch      = "thunar",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {LCD},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.float, -- Use the tile layout
        class       = {"Thunar", "spacefm", "pcmanfm", "xarchiver", "Squeeze", "File-roller", "Nautilus"}
    },
    {
        name        = "6:Edit",                 -- Call the tag "Term"
        key         = "6",
        launch      = "gvim",
        init        = false,                   -- Load the tag on startup
        exclusive   = false,                   -- Refuse any other type of clients (by classes)
        screen      = {VGA},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.max, -- Use the tile layout
        class       = {"jetbrains-pycharm-ce", "Geany", "gvim", "Firebug", "sun-awt-X11-XFramePeer", "Devtools", "jetbrains-android-studio", "sun-awt-X11-XDialogPeer"}
    },
    {
        name        = "7:Media",                 -- Call the tag "Term"
        key         = "7",
        launch      = "ario",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {LCD},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.float, -- Use the tile layout
        class       = {"MPlayer", "ario", "Audacious", "pragha", "mplayer2", "bino", "mpv"}
    },
    {
        name        = "8:Emu",                 -- Call the tag "Term"
        key         = "8",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {VGA},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        class       = {"VirtualBox"}
    },
    {
        name        = "9:Mediafs",                 -- Call the tag "Term"
        key         = "9",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {VGA},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        class       = {"xbmc.bin", "Kodi"}
    },
    {
        name        = "10:Remote",                 -- Call the tag "Term"
        key         = "x",
        launch      = "xterm -class xbmcremote -e python2 /usr/bin/kodiremote -c",
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {LCD},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        class       = {"xbmcremote"}
    },
    {
        name        = "0:",                 -- Call the tag "Term"
        key         = "0",
        init        = false,                   -- Load the tag on startup
        fallback    = true,
        screen      = {VGA},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile -- Use the tile layout
    }
}

clientbuttons=awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus=c; c:raise() end),
    awful.button({ altkey }, 1, awful.mouse.client.move),
    awful.button({ altkey }, 3, awful.mouse.client.resize))


function pushincorner()
    local sel=client.focus
    local geometry=sel:geometry()
    geometry['x']=0
    geometry['y']=0
    sel:geometry(geometry)
end

function movecursor(x, y)
    local location = mouse.coords()
    location.x = location.x + x
    location.y = location.y + y
    mouse.coords(location)
end

function lock()
    awful.util.spawn("xlock force")
end

function locktoggle()
    local res = awful.util.pread("xlock toggle")
    local color = "#0080ff"
    if res == "DISABLED\n" then
        color = "FF0000"
    else
        color = "00FF00"
    end
    local fg= "FFFFFF"
    local notification = naughty.notify({title="Lock status", text="", fg=fg, bg=color, replaces_id=lockreplaceid})
    lockreplaceid = notification.id
end

function suspend()
    lock()
    awful.util.spawn("systemctl suspend")
end

function keymenu(keys, naughtytitle, naughtypreset)
    local noti = nil
    if naughtytitle then
        naughtyprop = naughtypreset or {}
        if not naughtyprop.position then
            naughtyprop.position = 'top_left'
        end
        local txt = ''
        for _, key in ipairs(keys) do
            local descr = key.help or ""
            txt = txt .. "\nPress " .. key.key .. " " .. descr
        end
        noti = naughty.notify({title=naughtytitle, timeout=0, text=txt, preset=naughtyprop})
    end
    keygrabber.run(function(mod, pkey, event)
        if event == "release" then return end
        local stopped = false
        local continue = false
        for _, key in ipairs(keys) do
            if key.key == pkey then 
                stopped = true
                keygrabber.stop()
                continue = key.callback()
            end
        end
        if not stopped then
            keygrabber.stop()
        end
        if noti then
            naughty.destroy(noti)
        end
        if continue then
            keymenu(keys, naughtytitle, naughtypreset)
        end
   end)
end

local shutdownkeys = { {key="s", help="for suspend", callback=suspend},
                       {key="r", help="for reboot", callback=function() awful.util.spawn("systemctl reboot") end},
                       {key="e", help="for logout", callback=awesome.quit},
                       {key="c", help="for reload", callback=awesome.restart},
                       {key="p", help="for poweroff", callback=function() awful.util.spawn("systemctl poweroff") end},
                       {key="l", help="for lock", callback=lock}
                    }

function movetag(offset, idx) 
    local screen=client.focus.screen
    local tag = awful.tag.selected(screen)
    local idx = idx or awful.tag.getidx(tag)
    idx = idx + offset
    if idx <= 0 then
        idx = 1
    end
    local nrtags = #awful.tag.gettags(screen)
    if idx > nrtags then
        idx = nrtags
    end
    awful.tag.move(idx, tag)
end

function rename_tag()
    awful.prompt.run({ prompt = "Enter new tag:" },
    widgets.myprompt,
    function(new_name)
       if not new_name or #new_name == 0 then
          return
       else
          local screen = mouse.screen
          local tag = awful.tag.selected(screen)
          if tag then
             tag.name = new_name
          end
       end
    end)
end

function newtag()
    awful.prompt.run({ prompt = "Enter tag name:" },
    widgets.myprompt,
    function(new_name)
       if not new_name or #new_name == 0 then
          return
       else
          local screen = mouse.screen
          awful.tag.new({new_name}, screen)
       end
    end)
end

function movetagtoscreen()
    if client.focus then
        local t = client.focus:tags()[1]
        local s = awful.util.cycle(screen.count(), awful.tag.getscreen(t) + 1)
        awful.tag.history.restore()
        if not s or s < 1 or s > screen.count() then return end
        awful.tag.setscreen(t, s)
        awful.tag.viewonly(t)
    end
end


function movetagmenu()
    local keys = { {key="Left", help="Move Left", callback=function () movetag(-1); return true; end},
                   {key="Right", help="Move Right", callback=function () movetag(1); return true end}
                 }
    for i=1, 9 do
        keys[#keys+1] = {key=string.format("%s", i), help=string.format("Move to position %s", i), callback=function () movetag(0, i) end}

    end
    keymenu(keys, "Move Tag", {})

end

function xbmcmote()
    function togglekb()
        local output = awful.util.pread("xbmcmote kb")
        naughty.notify({title="Remote Keyboard", timeout=5, text=output})
    end
    local keys = { {key="r", help="Toggle Remote", callback=togglekb},
                   {key="x", help="Switch VT", callback=function () awful.util.spawn("xbmcmote x") end},
                   {key="s", help="Sleep", callback=function () awful.util.spawn("xbmcmote s") end},
                   {key="w", help="Wakeup", callback=function () awful.util.spawn("xbmcmote w") end}
                 }
    keymenu(keys, "XBMCMote", {})
end

local tagkeys = { {key="n", help="New", callback=newtag},
                  {key="r", help="Rename", callback=rename_tag},
                  {key="m", help="Move", callback=movetagmenu},
                  {key="s", help="Move to Screen", callback=movetagtoscreen},
                  {key="d", help="Delete", callback=function () 
                    local t = awful.tag.selected() 
                    awful.tag.delete(t)
                  end}
                }

keydoc.group("Launchers")
keybindings = awful.util.table.join(
    awful.key({ capskey, }, "F1", keydoc.display, "This"),
    awful.key({ altkey, "Control" }, "c", function () awful.util.spawn(terminal) end, "Open Terminal"),
    awful.key({ }, "Print", function () awful.util.spawn("caputereimg.sh /home/Jo/Pictures/SS") end, "Take Screenshot"),
    awful.key({ winkey,           }, "o", function () awful.util.spawn("rotatescreen") end, "Rotate Screen"),
    awful.key({ }, "XF86Battery", suspend, "Suspend"),
    awful.key({ capskey}, "v", myrc.util.resortTags, "Resort Tags"),
    awful.key({  }, "Caps_Lock", function() awful.util.spawn_with_shell("fixkeyboard") end, "Reset Keyboard mods"),
    awful.key({ capskey }, "r", function() awful.util.spawn("rofi -show run") end, "Run commands"),
    awful.key({ capskey }, "i", function() awful.util.spawn("rofi -modi 'Snippets:rofisnippets' -show Snippets") end, "Copy snippet"),
    awful.key({ capskey }, "w", function() awful.util.spawn("rofi -show window") end, "Search open windows"),
    keydoc.group("Music"),
    awful.key({ winkey,           }, "F2", function () awful.util.spawn("musiccontrol PlayPause") end, "Play/Resume"),
    awful.key({ winkey,           }, "F3", function () awful.util.spawn("musiccontrol Previous") end, "Previous"),
    awful.key({ winkey,           }, "F4", function () awful.util.spawn("musiccontrol Next") end, "Next"),
    keydoc.group("Screen"),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn_with_shell("xbacklight -inc 10") end, "Brightness +"),
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn_with_shell("xbacklight -dec 10") end, "Brightness -"),
    awful.key({ winkey, }, "l", locktoggle, "Toggle Autolock"),
    awful.key({ winkey,           }, "p", function () awful.util.spawn( "xrandr.sh --auto") end, "Dual/Single Toggle"),
    keydoc.group("Menus"),
    awful.key({ capskey}, "s", function() keymenu(shutdownkeys, "Shutdown", {bg="#ff3333", fg="#ffffff"}) end, "Shutdown Menu"),
    awful.key({ capskey}, "t", function() keymenu(tagkeys, "Tag Management", {}) end, "Tag Management"),
    awful.key({ capskey,  }, "z", xbmcmote, "Kodi Menu"),
    keydoc.group("Windows"),
    awful.key({ capskey,           }, "u", function () 
        awful.client.urgent.jumpto()
        removeFile('/tmp/scrolllock')
    end, "Jump to urgent"),
    awful.key({ winkey }, "d", awful.tag.viewnone, "Show desktop"),

    -- Mouse cursor bindings
    keydoc.group("Mouse Control"),
    awful.key({ capskey, "Shift" }, "Left", function () movecursor(-10,0) end, "Move left"),
    awful.key({ capskey, "Shift" }, "Right", function () movecursor(10,0) end, "Move right"),
    awful.key({ capskey, "Shift" }, "Up", function () movecursor(0,-10) end, "Move up "),
    awful.key({ capskey, "Shift" }, "Down", function () movecursor(0,10) end, "Move down")
)


client.connect_signal("property::urgent", function(c) 
    local window = nil
    if client.focus then
        window = client.focus.window
    end
    if c.urgent and c.window ~= window then
        awful.util.spawn("scrolllock")
    elseif not awful.client.urgent.get() then
        removeFile('/tmp/scrolllock')
    end
end)

hs.loadSpoon("ReloadConfiguration")
--- spoon.ReloadConfiguration:start()
-- Reload configuration on changes to .lua files only https://github.com/adamgibbins/hammerspoon-config/blob/master/init.lua
pathWatcher = hs.pathwatcher.new(hs.configdir, function(files)
  for _,file in pairs(files) do
    if file:sub(-4) == '.lua' then
      hs.reload()
    end
  end
end)
pathWatcher:start()



--- hammerspoon initialization
hs.window.animationDuration = 0 -- disable animations
hs.window.setFrameCorrectness = false   -- default=false
hs.hotkey.alertDuration = 0.25; -- default 1

--- console clear helper function {{{
--- see https://twitter.com/_hammerspoon/status/1068546178286010369
_modal_hammerspoon = hs.hotkey.modal.new():bind({"cmd"},"k",nil,function()
    hs.console.clearConsole()
    print "cleared"
end)
hs.application.watcher.new( function(name,type,app)
    if name == "Hammerspoon" then
        if type == hs.application.watcher.activated then
            _modal_hammerspoon:enter()
        else
            _modal_hammerspoon:exit()
        end
    end
end ):start()
--- }}}


--- general meta-key sequences for controlling various spoons
mish = {"ctrl",        "cmd"}
mash = {"ctrl", "alt", "cmd"}

--- show hotkeys
hs.hotkey.showHotkeys(mash,"k")


-- -------- window management ----------------------------------------------------- {{{
--- miro window manager to 'throw' windows to edges
hs.loadSpoon("MiroWindowsManager")
spoon.MiroWindowsManager.GRID  = { w = 24, h = 24 }
spoon.MiroWindowsManager.sizes = { 6/5, 4/3, 3/2, 2/1, 3/1, 4/1 }
spoon.MiroWindowsManager:bindHotkeys({
    up    = {mash, "up"},
    right = {mash, "right"},
    down  = {mash, "down"},
    left  = {mash, "left"},
    fullscreen = {mash, "f"}
})

--- winwin to move windows around and also move from screen to screen 
hs.loadSpoon("WinWin")
spoon.WinWin.gridparts = 24
function centerCursor(cwin)
    local wf = cwin:frame()
    local cscreen = cwin:screen()
    local cres = cscreen:fullFrame()
    if cwin then
        -- Center the cursor one the focused window
        hs.mouse.setAbsolutePosition({x=wf.x+wf.w/2, y=wf.y+wf.h/2})
    else
        -- Center the cursor on the screen
        hs.mouse.setAbsolutePosition({x=cres.x+cres.w/2, y=cres.y+cres.h/2})
    end
end
hs.hotkey.bind( mash, "[", "screen left", function()
    local cwin = hs.window.focusedWindow()
    spoon.WinWin:moveToScreen("left");
    centerCursor(cwin)
end)
hs.hotkey.bind( mash, "]", "screen right", function()
    local cwin = hs.window.focusedWindow()
    spoon.WinWin:moveToScreen("right");
    centerCursor(cwin)
end)
hs.hotkey.bind( mish, "left", "move left", function()
    local cwin = hs.window.focusedWindow()
    spoon.WinWin:stepMove("left");
    centerCursor(cwin)
end)
hs.hotkey.bind( mish, "right", "move right", function()
    local cwin = hs.window.focusedWindow()
    spoon.WinWin:stepMove("right");
    centerCursor(cwin)
end)
hs.hotkey.bind( mish, "up", "move up", function()
    local cwin = hs.window.focusedWindow()
    spoon.WinWin:stepMove("up");
    centerCursor(cwin)
end)
hs.hotkey.bind( mish, "down", "move down", function()
    local cwin = hs.window.focusedWindow()
    spoon.WinWin:stepMove("down");
    centerCursor(cwin)
end)
-- -------- window management ----------------------------------------------------- }}}
hs.window.filter.forceRefreshOnSpaceChange = true   -- force scan of windows on every space change (vs lazy discovery), can force scan w/ switchedToSpace(n)

function _layout(w,i)   --- {{{ layer,app,active,front,hide,space,screen,geom
--  https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/WinPanel/Concepts/ChangingMainKeyWindow.html

    local wk = hs.window.focusedWindow() --  ?isFocused? # NSWindow.isKeyWindow
    local wf = hs.window.frontmostWindow()
    i = i or 0
    w = w or wk or wf
    local a = w:application()
    local name  = string.format("%-20s",a:name())      -- really a:title()
    local active = hs.application.frontmostApplication():name() == a:name() and "ACT" or "not"
    local front = a:isFrontmost()   and "FRONT" or " back"
    local hide  = a:isHidden()      and "HIDE"  or "show"

    --- space
    local space = "space"

    --- screen
    local s= w:screen()
    local sx,sy= s:position()
    local screen= string.format( "[%d:%d]%-14s", sx, sy, s:name())        -- primary if has menubar, main has focus (somewhere)

    --- window geom
    local frame = w:frame()
    local geom  = string.format("+%5d+%5d@%5dx%5d",frame.x,frame.y,frame.w,frame.h)

    --- window attrs
    local id    = w:id()
    local role  = w:role()
    local sub   = w:subrole()
    local main  = a:mainWindow() and a:mainWindow():id() == id and "MAIN" or "idle"

    local vis   = w:isVisible()     and "VIS"   or "inv"
    local full  = w:isFullScreen()  and "FULL"  or "norm"
    local zoom  = "zoom"
    local std   = w:isStandard()    and "STD"   or "nsd"
    local min   = w:isMinimized()   and "MIN"   or "shw"

    local tab   = w:tabCount() or 0

    local layer = string.format("%d",i)             -- walk the ordered list and save position?
    local focus = wk:id() == id and "focus" or "nofoc"

    local title = w:title()

    local t = {
        -- app
        name, active, front, hide,
        -- win
        space, screen, geom,
        string.format("%3d",layer),
        focus,
        role, sub, main, std,
        tab,
        vis, full, zoom, min,
        string.format("%6d",id),
        title,
        ""
    }
    return t
end  --- }}}
function layout() --- get all window layouts {{{
--  local winlist = hs.windows.allWindows()         -- or visibleWindows, orderedWindows, get, find
--  -- hs.window.filter.default
--          filterOverride
--          filterbyApp
--          filterbyAttrib
--          ignoreAlways, allowedWindowRoles
--          attrib filters: visible,currentSpace,fullscreen,hasTitlebar,focused,activeApplication,allowRoles,{allow,reject}{Screens,Regions,Titles}
    local winlist = hs.window.filter.default:getWindows()
    local out = {}
    for i=1, #winlist do
        table.insert( out, _layout(winlist[i],i) )
        print(table.concat(_layout(winlist[i],i),","))
    end
--  table.sort(out,function(a,b) return a.name < b.name or a.id < b.id end)
--  table.foreachi(out,function(r)
--      print(table.concat(r,","))
--  end)
    return out
end
--- }}}
hs.hotkey.bind(mash, "l", nil, function() hs.openConsole(true); layout() end)


-- -------- ctrl cut-n-paste ----------------------------------------------------- {{{
--- ctrl-keys here vs sysprefs allows you to continue to use regular shortcuts AND these additional shortcuts
--- TODO: ensure application under the cursor is active?
--- hs.hotkey.bind({"ctrl"}, "a", "all", function() hs.eventtap.keyStroke({"cmd"}, "a") end)
--- hs.hotkey.bind({"ctrl"}, "c", "copy",  function() hs.eventtap.keyStroke({"cmd"}, "c") end)
--- hs.hotkey.bind({"ctrl"}, "v", "paste", function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
-- -------- cut-n-paste ----------------------------------------------------- }}}


-- -------- misc spoons: caffeine,redshift,mousecircle,micmute ----------------------------------------------------------- {{{
--- caffeine display keepalive
hs.loadSpoon("Caffeine");
spoon.Caffeine:start():clicked();

-- redshift
-- hs.redshift.start(1800,"17:00","08:00")
-- hs.hotkey.bind(mash, "r", "redshift toggle", nil, hs.redshift.toggle)

--- circleclock
--- hs.loadSpoon("CircleClock");
--- spoon.CircleClock:show();

--- MouseCircle -- [W]here is my mouse cursor?
hs.loadSpoon("MouseCircle");
--- spoon.MouseCircle:bindHotkeys({ show = {mash, "w"} });
hs.hotkey.bind(mash, "w", "WhereCursor", function() spoon.MouseCircle:show() end)

--- MicMute
hs.loadSpoon("MicMute")
spoon.MicMute:updateMicMute(-1)
hs.hotkey.bind(mash, "m", "MicMute", function() spoon.MicMute:toggleMicMute() end)
--- instead walk audiodevices and mute/unmute all isInputDevice()
-- -------- misc spoons ----------------------------------------------------------- }}}


-- -------- audio print devicedevice ----------------------------------------------------- {{{
function pct(v)
    return string.format("%3d%%",int(v))
end
function int(v)
    return math.floor(tonumber(v))
end
function _auprint(d)
    local uid_in = hs.audiodevice.defaultInputDevice():uid()
    local uid_out = hs.audiodevice.defaultOutputDevice():uid()

    local mutekey = "mute_vol/"..d:uid()
    local mutevol = hs.settings.get(mutekey) and pct(hs.settings.get(mutekey)) or "   -"
    print(table.concat({
        (d:uid()==uid_in    and "defi"                  or "   -"),
        (d:uid()==uid_out   and "defo"                  or "   -"),
        (d:isInputDevice()  and "in"                    or " -"),
        (d:isOutputDevice() and "out"                   or "  -"),
        (d:jackConnected()  and "jacked"                or "nojack"),
        (d:inputMuted()     and "imute"                 or "    -"),
        (d:outputMuted()    and "omute"                 or "    -"),
        (d:inputVolume()    and pct(d:inputVolume())    or "  ni"),
        (d:outputVolume()   and pct(d:outputVolume())   or "  no"),
        (mutevol~=nil       and mutevol                 or "-"),
                                string.format("%-12s", d:transportType()),
                                string.format("%-16s", d:name()),
                                string.format("%s",   d:uid())
        },","))

end
function auprint()
    local aulist = hs.audiodevice.allDevices()
    for i=1, #aulist do
        _auprint(aulist[i])
    end
end
--- }}}
hs.hotkey.bind(mash, "a", nil, function() hs.openConsole(true); auprint() end)

-- watch every device
function auwatch()
    local aulist = hs.audiodevice.allDevices()
    for i=1, #aulist do
        local d = aulist[i]
        d:watcherCallback( function(uid,name,scope,element)
            print("                                                                                 "..uid..","..name..","..scope..","..element)
            local dev =hs.audiodevice.findDeviceByUID(uid)
            _auprint(dev)
        end):watcherStart()
    end
end
auwatch()

--- hs.audiodevice.watcher.setCallback( function() if defout has no volume, find first that does, setdefout; end )
--  hs.audiodevice.watcher.start()


-- -------- spotify ----------------------------------------------------- {{{
-- spotify what's playing
-- spotpop = {}
-- spotpop.was = ""
-- spotpop.delay = { 10, 60 }
-- spotpop.timer = hs.timer.delayed.new(spotpop.delay[1],function()
--     spotpop.now = hs.spotify.getCurrentTrack()
--         .. "|" .. hs.spotify.getCurrentAlbum()
--         .. "|" .. hs.spotify.getCurrentArtist()
--         .. "|" .. hs.inspect(hs.spotify.isPlaying());
-- 
--     if spotpop.now ~= spotpop.was then
--         hs.spotify.displayCurrentTrack()
--         spotpop.was = spotpop.now
--     end
-- 
--     delay = spotpop.delay[1]
--     if not hs.spotify.isPlaying then
--         spotpop.delay = spotpop.delay[2]
--     end
--     spotpop.timer:start(delay)
-- end)
-- spotpop.timer:start()

-- https://github.com/cparnot/ASCIImage
-- samechar twice = line
-- samechar 3+ = circle
music_note = hs.image.imageFromASCII( [[
...............
...............
........b......
........A......
...............
............b..
...............
...............
....111........
...1...1A......
..1.....1......
..11...1.......
....111........
...............
...............
]] )

spottimer = hs.timer.delayed.new(5,function() showspot() end);
function showspot()
    if hs.spotify.isPlaying() then
        local pos = math.floor( hs.spotify.getPosition() )
        local dur = math.floor( hs.spotify.getDuration() )
        local rem = math.floor( dur - pos )
        local pct = pos*100//dur
        local doz = 10
        local artist = hs.spotify.getCurrentArtist()
        local album = hs.spotify.getCurrentAlbum()
        local track = hs.spotify.getCurrentTrack()
        local mesg = "" ..
            track .. "\n" ..
            album .. "\n" ..
            artist .. "\n" ..
            pos .. "/" .. dur .. "=" .. pct .. "%" .. " rem " .. rem ..
            "";
        if dur < 32 then
            mesg = "COMMERCIAL:\n\n" .. mesg
--          doz = rem+5
        else
        end
        print( "song:\n" .. mesg );
        hs.notify.new({
            title = track,
            subTitle = album,
            informativeText = artist,
            withDrawAfter = doz,
            setIdImage = music_note
        }):send();
        spottimer:setDelay(rem+2)       -- to catch commercials that are not announced via notification
        spottimer:start()
    end
end
spot = hs.distributednotifications.new(
    function(name, object, userInfo)
        if object == 'com.spotify.client' then
            if userInfo then
                showspot()
            else
                print( "commercial:" );
            end
            print( string.format( "name: %s\nobject: %s\nuserInfo: %s\n", name,       object,       hs.inspect(userInfo)))
            local trackid = userInfo["Track ID"]:match(".*:.*:(.*)")
--          if trackid then
--              -- hs.http.asyncGet( "" )
--          end
        end
    end
)
spot:start()
hs.hotkey.bind( {"ctrl","alt","cmd"}, "s", nil, function() showspot() end )
-- -------- spotify ----------------------------------------------------- }}}

-- playing with focus follows mouse only once it goes idle
-- MouseTrack
-- hs.loadSpoon("MouseIdle")


-- app watcher - start/stop apps - maybe mojave show up here? not clearly...
_appeventtype = { "launching", "launched", "terminated", "hidden", "unhidden", "activated", "deactivated" }
hs.application.watcher.new( function( name, type, app )
    name = name and name or "noname"
    if type+1 < 6 then  -- ignore activated/deactivated
        print( "APP EVENT: type=" .. _appeventtype[type+1] .. ", name="..name )
    end
end):start()

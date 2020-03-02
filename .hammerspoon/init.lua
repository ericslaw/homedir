-- lua initialization for hammerspoon
-- 

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

sortbykv = hs.fnutils.sortByKeyValues


imap = hs.fnutils.imap
-- TODO; how does this map to hs.fnutils.map or imap?
function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

function disp_rect( can, rectlist )
    local dstctr = hs.geometry.rect( can:frame() ).center
    local scale = 0.2

    for i,of in ipairs(rectlist) do
        local nf = hs.geometry.rect(
            of.x * scale + dstctr.x*scale,  -- bug here for sure
            of.y * scale + dstctr.y*scale,  -- bug here for sure
            of.w * scale,
            of.h * scale
        ):floor()
        can:insertElement({ type = "rectangle", fillColor = { alpha = 0.5, green=0.5 }, frame = {x=nf.x,y=nf.y,w=nf.w,h=nf.h} })
        local color = { red=0.8,green=0.8,blue=0.8 }
        if (of.color ) then
            color = of.color
        end
        if (of.text) then
            can:insertElement({ type = "text", text=of.text, textSize=10, frame = {x=nf.x,y=nf.y,w=nf.w,h=nf.h}, fillColor=color })
        end
    end
end

--  TODO: below breaks if no display to east
-- can = hs.canvas.new( hs.screen:primaryScreen():toEast():fullFrame():scale(0.5):floor() )
can = hs.canvas.new( hs.screen:primaryScreen():fullFrame():scale(0.5):floor() )
function disp_all()
    local gry = { red=0.5, green=0.5, blue=0.5, alpha=0.5 }
    local grn = { red=0.2, green=1.0, blue=0.2, alpha=0.9 }
    local blu = { red=0.1, green=0.1, blue=5.0, alpha=0.1 }

    can:replaceElements()
    scrlist = imap(hs.screen.allScreens(),                  function(s)local f=s:fullFrame();f.color=blu;                  return f;end)
    winlist = imap(hs.window.filter.new(true):getWindows(), function(w)local f=w:frame();    f.color=grn; f.text=w:title();return f;end)

    disp_rect( can, scrlist )
    disp_rect( can, winlist )

    can:show()
    hs.timer.doAfter(4,function() can:hide(2) end)
end


--- hammerspoon initialization
hs.window.animationDuration = 0 -- disable animations
hs.window.setFrameCorrectness = false   -- default=false
hs.hotkey.alertDuration = 0.25; -- default 1



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
hs.hotkey.bind( mash, "[",      "screen left",  function() local cwin = hs.window.focusedWindow() spoon.WinWin:moveToScreen("left")  centerCursor(cwin) end)
hs.hotkey.bind( mash, "]",      "screen right", function() local cwin = hs.window.focusedWindow() spoon.WinWin:moveToScreen("right") centerCursor(cwin) end)
hs.hotkey.bind( mish, "left",   "move left",    function() local cwin = hs.window.focusedWindow() spoon.WinWin:stepMove("left")      centerCursor(cwin) end)
hs.hotkey.bind( mish, "right",  "move right",   function() local cwin = hs.window.focusedWindow() spoon.WinWin:stepMove("right")     centerCursor(cwin) end)
hs.hotkey.bind( mish, "up",     "move up",      function() local cwin = hs.window.focusedWindow() spoon.WinWin:stepMove("up")        centerCursor(cwin) end)
hs.hotkey.bind( mish, "down",   "move down",    function() local cwin = hs.window.focusedWindow() spoon.WinWin:stepMove("down")      centerCursor(cwin) end)

-- -------- window management ----------------------------------------------------- }}}
hs.window.filter.forceRefreshOnSpaceChange = true   -- force scan of windows on every space change (vs lazy discovery), can force scan w/ switchedToSpace(n)
function _screen(scr)
    local name,id,uuid,frame = scr:name(), scr:id(), scr:getUUID(), scr:fullFrame()
    return string.format("screen:%10s:%5s:%5d,%5d@%4dx%4d:%11s",id,uuid,frame.x,frame.y,frame.w,frame.h,name)
end
function _layout(w,i)   --- {{{ layer,app,active,front,hide,space,screen,geom
--  https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/WinPanel/Concepts/ChangingMainKeyWindow.html

    local wk = hs.window.focusedWindow() --  ?isFocused? # NSWindow.isKeyWindow
    local wf = hs.window.frontmostWindow()
    i = i or 0
    w = w or wk or wf
    local a = w:application()
    local name      = string.format("%-20s",a:name())      -- really a:title()
    local active    = hs.application.frontmostApplication():name() == a:name() and "ACT" or "not"
    local front     = a:isFrontmost()   and "FRONT" or " back"
    local hide      = a:isHidden()      and "HIDE"  or "show"

    --- space
    local space = "space"

    --- screen
    local s= w:screen()
--  local sx,sy= s:position()
--  local screen= string.format( "[%d:%d]%-14s", sx, sy, s:name())        -- primary if has menubar, main has focus (somewhere)
    local screen=_screen(s)

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
-- window levels: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/WinPanel/Concepts/WindowLevel.html#//apple_ref/doc/uid/20000227-136682
-- NS{Normal|Floating|ScreenSaver|Status|ModelPanel|PopUpMenu|TornOffMenu|MainMenu}WindowLevel
function layout() --- get all window layouts {{{
    kl()
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
--  table.sort(out,function(a,b)
--      return a.name < b.name or a.id < b.id
--  end)
--  print(hs.inspect(out))
    return out
end
--- }}}
hs.hotkey.bind(mash, "l", nil, function() disp_all() end)


-- -------- ctrl cut-n-paste ----------------------------------------------------- {{{
--- ctrl-keys here vs sysprefs allows you to continue to use regular shortcuts AND these additional shortcuts
--- TODO: ensure application under the cursor is active?
--- hs.hotkey.bind({"ctrl"}, "a", "all", function() hs.eventtap.keyStroke({"cmd"}, "a") end)
--- hs.hotkey.bind({"ctrl"}, "c", "copy",  function() hs.eventtap.keyStroke({"cmd"}, "c") end)
--- hs.hotkey.bind({"ctrl"}, "v", "paste", function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
-- 'nil' required above for function to run AFTER you release the key, at expense of losing the 'why' field
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


-- -------- mute toggle ----------------------------------------------------------- {{{
-- my_mute_toggle requires system down and up event posted to work
function my_mute_toggle() hs.eventtap.event.newSystemKeyEvent("MUTE",true):post();hs.eventtap.event.newSystemKeyEvent("MUTE",false):post() end
function my_mute_delay(nsec) my_mute_toggle(); hs.timer.doAfter(nsec, function() my_mute_toggle() end) end

--- eject key binding on BT keyboard
-- see: https://github.com/Hammerspoon/hammerspoon/issues/1220
-- see also: https://github.com/Hammerspoon/hammerspoon/issues/2115
ejecttap = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
    -- http://www.hammerspoon.org/docs/hs.eventtap.event.html#systemKey
    event = event:systemKey()
    -- http://stackoverflow.com/a/1252776/1521064
    local next = next
    -- Check empty table
    if next(event) then
        if event.key == 'EJECT' and event.down then
            print('mute 28sec')
            my_mute_delay(24)
        end
    end
end):start()
-- -------- mute toggle ----------------------------------------------------------- }}}


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
img_music_note = hs.image.imageFromASCII( [[
...............
...............
........b......
........A......
...............
............b..
...............
...............
....CCC........
...C...CA......
..C.....C......
..CC...C.......
....CCC........
...............
...............
]] )
img_clock = hs.image.imageFromASCII( [[
...111...
..1...1..
.1....41.
1..2.#..1
1...3...1
1.......1
.1.....1.
..1...1..
...111...
]] )
img_question = hs.image.imageFromASCII( [[
..........
....2..3..
..........
..1......4
..........
.........5
.....76...
..........
..........
.....a....
]] )

chime_timer = hs.timer.delayed.new(5,function() end);
function chime()
    hs.notify.new({
        setIdImage = img_clock,
        title = "chime",
        subTitle = "what time is it?",
        informativeText = "what are you doing",
        withDrawAfter = 10
    }):send()
    chime_timer:setDelay(ival)
    chime_timer:start()
end

spot_timer = hs.timer.delayed.new(5,function() showspot() end);
function showspot()
    if hs.spotify.isPlaying() then
        local pos = math.floor( hs.spotify.getPosition() )
        local dur = math.floor( hs.spotify.getDuration() )
        local rem = math.floor( dur - pos )
        local pct = pos*100//dur                -- // turns it into int
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
            mesg = "CoMmErCiAl:\n\n" .. mesg
            my_mute_delay(dur)      --== !!! warning !!! no logic to cancel this in any way
--          doz = rem+5
        else
            mesg = "song:\n\n" .. mesg
        end
--      print( "song:\n" .. mesg );
        hs.notify.new({
            setIdImage = img_music_note,
            title = track,
            subTitle = "on ".. album,
            informativeText = "by " .. artist,
            withDrawAfter = doz
        }):send();
        spot_timer:setDelay(rem+2)       -- to catch commercials that are not announced via notification
        spot_timer:start()
    end
end
spot = hs.distributednotifications.new(
    function(name, object, userInfo)
        if object == 'com.spotify.client' then
            if userInfo then
                showspot()
            else
                print( "commercial:" );
                print( string.format( "name: %s\nobject: %s\nuserInfo: %s\n", name,       object,       hs.inspect(userInfo)))
            end
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

--- console clear helper function {{{

--- see https://twitter.com/_hammerspoon/status/1068546178286010369
--- provide keymapping (cmd-k) only when specific app (hammerspoon) is activated

_modal_hammerspoon = hs.hotkey.modal.new();

--- _modal_hammerspoon:bind({"cmd"},"f",nil,function()
---     spoon.MouseIdle:start();
---     print("mouseidle started");
--- end);
--- _modal_hammerspoon:bind({"shift","cmd"},"f",nil,function()
---     spoon.MouseIdle:stop();
---     print("mouseidle stopped");
--- end);

function kl() hs.console.clearConsole(); end

_modal_hammerspoon:bind({"cmd"},"k",nil,function()
    hs.console.clearConsole();
end);
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

-- playing with focus follows mouse only once it goes idle
-- MouseIdle
-- hs.loadSpoon("MouseIdle")


-- app watcher - start/stop apps - maybe mojave show up here? not clearly...
_appeventtype = { "launching", "launched", "terminated", "hidden", "unhidden", "activated", "deactivated" }
hs.application.watcher.new( function( name, type, app )
    name = name and name or "noname"
    if type+1 < 6 then  -- ignore activated/deactivated
        print( "APP EVENT: type=" .. _appeventtype[type+1] .. ", name="..name )
    end
end):start()


-- countdown
-- hs.loadSpoon("CountDown")
-- spoon.CountDown:startFor(60)


--function foo()
--    local box = hs.geometry.rect(0,0,0,0)
--    for i,s in ipairs(hs.screen.allScreens()) do
--        box = box:union(s:frame():floor())
--        print(box)
--    end
--    for i,w in ipairs(hs.window.allWindows()) do
--        print("box:",box )
--        print("w:f:",w:frame() )
--        print("w:f:u:",w:frame():toUnitRect(box) )
--        print("can:", table.unpack(can:frame()) )
--        print("w:f:u:",w:frame():toUnitRect(box):fromUnitRect(can:frame()) )
--        print("...")
--        can:insertElement({
--            type = "rectangle", action="stroke", -- fillColor = { alpha = 0.5, green=0.5 },
--            frame = table.unpack( w:frame():toUnitRect(box):fromUnitRect(can:frame()):floor() )
--        }):show()
--    end
--end


--  for i,s in ipairs(hs.screen.allScreens()) do
--      print( s:uuid(), s:fullFrame():floor(), s:rotate() )
--  end


--##
--## save/load screen config - handles primary+origin+rotate
--## maybe use underscore.lua? https://mirven.github.io/underscore.lua/#sort
--## may be relevant: XRnR for macos https://github.com/jakehilborn/displayplacer
--## 
--## key = sorted uuid list for current configuration
--## cfg = array of screens (primary first) of useful attributes from each screen
--## inv = ENTIRE set of screen configs by key
--## scr = hs.screen object
--## str = string represent
--##
--## TODO: remove underscore? is only used twice

_=require 'underscore'
function scr2cfg(s) -- screen to config struct
    local id,uuid,name,f,r,px,py = s:id(),s:getUUID(),s:name(),s:fullFrame(),s:rotate(),s:position()
    return { id=id, uuid=uuid, name=name, x=f.x, y=f.y, w=f.w, h=f.h, r=r, px=px,  py=py }
end
function cfg2str(c) -- config struct to string
    return string.format("screen:%10s:%5s:%5d,%5d@%4dx%4d:%2d,%2d:%11s",c.id,c.uuid,c.x,c.y,c.w,c.h,c.px,c.py,c.name)
end
function scr2str(s) -- screen struct to string
    return cfg2str( scr2cfg(s) )
end
function cfg2scr(c,s) -- config struct to screen -- ie: make changes
    if c.x == 0 and c.y == 0 and s:getUUID() ~= hs.screen.primaryScreen():getUUID() then    -- is NOT primary
        print("set primary " .. cfg2str(c) .. " >> " .. scr2str(s) )
        s:setPrimary()
    end
    if s:rotate() ~= c.r then
        print("set rotate  " .. cfg2str(c) .. " >> " .. scr2str(s) )
        s:rotate(c.r)
    end
    if s:fullFrame().x ~= c.x or s:fullFrame().y ~= c.y then
        print("set origin  " .. cfg2str(c) .. " >> " .. scr2str(s) )
        s:setOrigin(c.x,c.y)
    end
end
function getscrkey()
    return _(hs.screen.allScreens()):chain():map(function(s)return s:getUUID() end):sort():join(":"):value()
end
function showscrinv()
    local scrinv = hs.settings.get("scrinv") or {}
    for key,cfglist in pairs(scrinv) do
        print("key: "..key)
        for i,cfg in ipairs(cfglist) do
            print("    cfg".. i .. ": " .. cfg2str(cfg) )
        end
    end
end
function savescrinv()
    local scrkey = getscrkey()
    local scrcfglist = _(hs.screen.allScreens()):chain():map(function(s) return scr2cfg(s) end):value()
    local scrinv = hs.settings.get("scrinv") or {}
    scrinv[scrkey] = scrcfglist
    hs.settings.set("scrinv",scrinv)
end
function loadscrinv()
    local scrkey = getscrkey()
    local scrinv = hs.settings.get("scrinv") or {}
    if scrinv[scrkey] then
        for i,cfg in ipairs(scrinv[scrkey] ) do
            local scr = hs.screen.find(cfg.uuid)
            print("load cfg".. i .. ": " .. cfg2str(cfg) )
            cfg2scr( cfg, scr )
        end
    end
end

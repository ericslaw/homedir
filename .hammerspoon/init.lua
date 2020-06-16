--- lua initialization for hammerspoon

function trim(s) return string.match(s,'^%s*(.*%S)') or s end

--- reload config on .lua file change in tree {{{
hs.loadSpoon("ReloadConfiguration")
-- Reload configuration on changes to .lua files only
-- https://github.com/adamgibbins/hammerspoon-config/blob/master/init.lua
pathWatcher = hs.pathwatcher.new(hs.configdir, function(files)
  for _,file in pairs(files) do
    if file:sub(-4) == '.lua' then
      hs.reload()
    end
  end
end)
pathWatcher:start()
-- }}}
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

--- basic initialization
hs.window.animationDuration = 0         -- disable animations
hs.window.setFrameCorrectness = false  -- default=false -- set true if having issues
hs.hotkey.alertDuration = 0.25;         -- default 1    -- how long a hotkey press alert is displayed

--- general meta-key sequences for controlling various spoons
mish = {"ctrl",        "cmd"}
mash = {"ctrl", "alt", "cmd"}
hs.hotkey.showHotkeys(mash,"k")


--- ctrl cut-n-paste ---------------------------------------------------------- {{{
--  ctrl-keys here vs sysprefs allows you to continue to use regular shortcuts AND these additional shortcuts
--  TODO: ensure application under the cursor is active?
--  hs.hotkey.bind({"ctrl"}, "a", "all", function() hs.eventtap.keyStroke({"cmd"}, "a") end)
--  hs.hotkey.bind({"ctrl"}, "c", "copy",  function() hs.eventtap.keyStroke({"cmd"}, "c") end)
--  hs.hotkey.bind({"ctrl"}, "v", "paste", function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
-- 'nil' required above for function to run AFTER you release the key, at expense of losing the 'why' field
-- }}}
--- window management; miro + winwin ------------------------------------------ {{{
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

-- }}}
--- caffeine display keepalive ------------------------------------------------ {{{
hs.loadSpoon("Caffeine");
spoon.Caffeine:start():clicked();
-- }}}
--- MouseCircle -- [W]here is my mouse cursor? {{{
hs.loadSpoon("MouseCircle");
hs.hotkey.bind(mash, "w", "WhereCursor", function() spoon.MouseCircle:show() end)
-- }}}
--- MicMute [M]ute my mic {{{
hs.loadSpoon("MicMute")
spoon.MicMute:updateMicMute(-1)
hs.hotkey.bind(mash, "m", "MicMute", function() spoon.MicMute:toggleMicMute() end)
--- todo: instead walk audiodevices and mute/unmute all isInputDevice() ?  nah seems to work
-- }}}
--- Spotify notification and ad muting ---------------------------------------- {{{
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

-- #chime_timer = hs.timer.delayed.new(5,function() end);
-- #function chime()
-- #    hs.notify.new({
-- #        setIdImage = img_clock,
-- #        title = "chime",
-- #        subTitle = "what time is it?",
-- #        informativeText = "what are you doing",
-- #        withDrawAfter = 10
-- #    }):send()
-- #    chime_timer:setDelay(ival)
-- #    chime_timer:start()
-- #end

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
-- }}}

--- DISABLED ---
--- redshift / flux -- disabled {{{
-- hs.redshift.start(1800,"17:00","08:00")
-- hs.hotkey.bind(mash, "r", "redshift toggle", nil, hs.redshift.toggle)
-- }}}
--- circleclock -- disabled {{{
-- hs.loadSpoon("CircleClock");
-- spoon.CircleClock:show();
-- }}}
--- mute toggle keypress simulator -- disabled -------------------------------- {{{
-- my_mute_toggle requires system down and up event posted to work
function my_mute_toggle() hs.eventtap.event.newSystemKeyEvent("MUTE",true):post();hs.eventtap.event.newSystemKeyEvent("MUTE",false):post() end
function my_mute_delay(nsec) my_mute_toggle(); hs.timer.doAfter(nsec, function() my_mute_toggle() end) end

--- was using 'eject' on BT keyboard to mute audio for 25sec
-- see: https://github.com/Hammerspoon/hammerspoon/issues/1220 https://github.com/Hammerspoon/hammerspoon/issues/2115
ejecttap = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
    -- http://www.hammerspoon.org/docs/hs.eventtap.event.html#systemKey
    event = event:systemKey()
    -- http://stackoverflow.com/a/1252776/1521064
    local next = next
    -- Check empty table
    if next(event) then
        if event.key == 'EJECT' and event.down then
            print('mute 25sec')
            my_mute_delay(25)
        end
    end
end)
-- ejecttap:start()
-- }}}
--- MouseIdle - focus-follows-mouse - disabled -------------------------------- {{{
-- playing with focus follows mouse only once it goes idle
-- MouseIdle
-- hs.loadSpoon("MouseIdle")
-- }}}
--- countdown - pareto timer line drawn on screen - disabled ------------------ {{{
-- hs.loadSpoon("CountDown")
-- spoon.CountDown:startFor(60)
-- }}}



-- INVENTORIES
-- audiodevice {{{
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
-- hs.hotkey.bind(mash, "a", nil, function() hs.openConsole(true); auprint() end)

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

--  hs.audiodevice.watcher.setCallback( function() if defout has no volume, find first that does, setdefout; end )
--  hs.audiodevice.watcher.start()

--- }}}
-- window inventory {{{
-- anatomy  - https://developer.apple.com/design/human-interface-guidelines/macos/windows-and-views/window-anatomy/
--              frame panel dialog alert popover
-- states   - Main,Key,inactive
-- role     - http://mirror.macintosharchive.org/developer.apple.com/documentation/Accessibility/Reference/AccessibilityCarbonRef/Reference/reference.html#//apple_ref/doc/constant_group/Roles
-- subrole  - http://mirror.macintosharchive.org/developer.apple.com/documentation/Accessibility/Reference/AccessibilityCarbonRef/Reference/reference.html#//apple_ref/doc/constant_group/Subroles
-- levels   - https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/WinPanel/Concepts/WindowLevel.html#//apple_ref/doc/uid/20000227-136682
--            NS{Normal|Floating|ScreenSaver|Status|ModelPanel|PopUpMenu|TornOffMenu|MainMenu}WindowLevel
-- spaces?  - https://github.com/NUIKit/CGSInternal/blob/master/CGSSpace.h

-- window attributes?
--  frame       - position + size
--# main        - AXMain
--# focused     - has keyboard focus (mouse scrollbar focus is independent)
--# isMinimized - hide in dock AXMinimized
--# fullscreen  - fullscreen mode = no window decor
--# maximized   - resize to screensize and keep window decor - can be toggled?
--# isVisible   - visible at the moment (why do I care?)        == hidden && !minimized
--# level?      - stack level -- cannot set directly
--# role        - AXWindow|AXUnknown
--# subrole     - AXStandardWindow|AXFloatingWindow|AXSystemFloatingWindow|AXDialog|AXSysstemDialog|AXUnknown

--  w:isFullScreen()
--  w:isMinimized()
--  w:isStandard()
--  w:isVisible()
--  w:role()
--  w:subRole()
--  w:tabCount()

hs.window.filter.forceRefreshOnSpaceChange = true   -- force scan of windows on every space change (vs lazy discovery), can force scan w/ switchedToSpace(n)

-- win = hs.WINdow object, wcf = custom Window ConFig hash, str = string

function win2wcf(w,space) --- id space s x y w h app title
    space = space or ""
    local id,scr,f,app,ttl = w:id(), w:screen(), w:frame(), w:application(), w:title()
    return { id=id, space=space, s=scr:getUUID(), x=f.x,y=f.y,w=f.w,h=f.h, app=app:name(), title=ttl }
end
function wcf2win(d,w)
    w:move( hs.geometry.rect( d.x, d.y, d.w, d.h ), s )
end
function wcf2str(d)
    return string.format("win:%10d:%5s:%s:%5d,%5d@%4dx%4d:%-16s:%s",d.id,d.space,d.s,d.x,d.y,d.w,d.h,d.app,d.title)
end
function win2str(w,sp)
    return wcf2str(win2wcf(w,sp))
end
function getwcflist(space)
--  hs.window.filter.default:rejectApp("Slack Helper (Renderer)")
    local winfilt = hs.window.filter.default
    local winlist = winfilt:getWindows()        -- default sortByFocusedLast
    local wininv = {}
    for i,w in ipairs( winfilt:getWindows() ) do
        wininv[i] = win2wcf(w,space)
    end
    return wininv
end
function showwininv()
    local scrkey = getscrkey()
    local scrinv = hs.settings.get("scrinv") or {}
    local wininv = hs.settings.get("wininv") or {}
    local wcflist = wininv[scrkey]
    for _,d in ipairs( wcflist ) do
        print( wcf2str(d) )
    end
end
function savewininv()
    local scrkey = getscrkey()
    local scrinv = hs.settings.get("scrinv") or {}
    local wininv = hs.settings.get("wininv") or {}
    scrinv[scrkey] = getscrscflist()
    wininv[scrkey] = getwcflist()
    hs.settings.set("scrinv",scrinv)
    hs.settings.set("wininv",wininv)
end
function loadwininv()
    local scrkey = getscrkey()
    local scrinv = hs.settings.get("scrinv") or {}
    local wininv = hs.settings.get("wininv") or {}
    local wcflist = wininv[scrkey] -- not used?
    local winlist = hs.window.filter.default:getWindows()
    for _,w in ipairs( winlist ) do
        for _,d in ipairs( wcflist ) do
            if w:id() == d.id then
                wcf2win( d, w )
            end
        end
    end
end
-- }}}
-- screen inventory - load/save screen layouts {{{
--##
--## save/load screen config - handles primary+origin+rotate
--## maybe use underscore.lua? https://mirven.github.io/underscore.lua/#sort
--## may be relevant: XRnR for macos https://github.com/jakehilborn/displayplacer
--## example:
--##    _=require 'underscore'
--##    return _(hs.screen.allScreens()):chain():map(function(s)return s:getUUID() end):sort():join(":"):value()
--##    local scrcfglist = _(hs.screen.allScreens()):chain():map(function(s) return scr2cfg(s) end):value()
--## 
--## key = sorted uuid list for current configuration
--## cfg = array of screens (primary first) of useful attributes from each screen
--## inv = ENTIRE set of screen configs by key
--## scr = hs.screen object
--## str = string represent
--##

-- scr = hs.SCReen object, scf = custom Screen ConFig hash, str = string
function scr2scf(s) -- screen to config struct
    local id,uuid,name,f,r,bg,px,py = s:id(),s:getUUID(),s:name(),s:fullFrame(),s:rotate(),s:desktopImageURL(),s:position()
    return { id=id, uuid=uuid, name=name, x=f.x, y=f.y, w=f.w, h=f.h, r=r, px=px,  py=py, bg=bg }
end
function scf2str(c) -- config struct to string
    return string.format("scr:%10s:%5s:%5d,%5d@%4dx%4d:%2d,%2d:%-11s,%s", c.id,c.uuid, c.x,c.y,c.w,c.h,c.px,c.py,c.name,c.bg)
end
function scr2str(s) -- screen struct to string
    return scf2str( scr2scf(s) )
end
function scf2scr(c,s) -- config struct to screen -- ie: make changes
    if c.x == 0 and c.y == 0 and s:getUUID() ~= hs.screen.primaryScreen():getUUID() then    -- is NOT primary
        print("set primary " .. scf2str(c) .. " >> " .. scr2str(s) )
        s:setPrimary()
    end
    if s:rotate() ~= c.r then
        print("set rotate  " .. scf2str(c) .. " >> " .. scr2str(s) )
        s:rotate(c.r)
    end
    if s:fullFrame().x ~= c.x or s:fullFrame().y ~= c.y then
        print("set origin  " .. scf2str(c) .. " >> " .. scr2str(s) )
        s:setOrigin(c.x,c.y)
    end
    if s:desktopImageURL() ~= c.bg then
        print("set bg  " .. s:desktopImageURL() .. " >> " .. c.bg )
        s:desktopImageURL(c.bg)
    end
end
function getscrkey()
    local uuidlist = {}
    for i,s in ipairs(hs.screen.allScreens()) do
        uuidlist[i] = s:getUUID()
    end
    return table.concat(uuidlist,":")
end
function getscrscflist()
    local scrscflist = {}
    for i,s in ipairs(hs.screen.allScreens()) do
        scrscflist[i] = scr2scf(s)
    end
    return scrscflist
end
function showscrinv()
    local scrinv = hs.settings.get("scrinv") or {}
    for key,scflist in pairs(scrinv) do
        print("key: "..key)
        for i,scf in ipairs(scflist) do
            print("    scf".. i .. ": " .. scf2str(scf) )
        end
    end
end
function savescrinv()
    local scrkey = getscrkey()
    local scrscflist = getscrscflist()
    local scrinv = hs.settings.get("scrinv") or {}
    scrinv[scrkey] = scrscflist
    hs.settings.set("scrinv",scrinv)
end
function loadscrinv()
    local scrkey = getscrkey()
    local scrinv = hs.settings.get("scrinv") or {}
    if scrinv[scrkey] then
        for i,scf in ipairs(scrinv[scrkey] ) do
            local scr = hs.screen.find(scf.uuid)
            print("load scf".. i .. ": " .. scf2str(scf) )
            scf2scr( scf, scr )
        end
    end
end
function clearscrinv()
    hs.settings.clear("scrinv")
end
-- }}}


-- TODO: no screen change detected when laptop screen closes
-- TODO: tidy this pattern
-- multiple sporatic async events on scr change followed-by (?) win change events
-- each need debounced with timer
-- each triggers a save or load depending on state?
-- complication: load event is an 'ask' until approved but notif dont stay open for more than 4sec
-- idea: maybe set flags saying what happened to make logic more clear

-- timer to run when window inventory should be loaded soon
screenload_pending = false
screenload_notif = hs.notify.new(function(notif)
    -- activationTypes = 0=none 1=contentsClicked 2=actionButtonClicked 3=replied 4=additionalActionClicked
    if notif:activationType() == hs.notify.activationTypes["actionButtonClicked"] then
        print("loadwininv()")
        loadwininv()
    else
        print("will NOT loadwininv()")
    end
    screenload_pending = false
end,{
    soundName = "Glass",
    setIdImage = img_question,
    title = "loadinv",
    subTitle = "should I load inventory?",
    informativeText = "do you think so?",
    hasActionButton = true,
    actionButtonTitle = "LoadWinInv",
    autoWithdraw = false,
    withDrawAfter = 120
})
screenload_timer = hs.timer.delayed.new(10, function()
    screenload_notif:send()
end)
-- watch for screen add/sub/mov events and trigger the ask-load 
hs.screen.watcher.new(function()
    screenload_pending = true
    screenload_timer:start(10)
    print("screen watcher event; start load in 10sec")
end):start()
-- TODO: have save functoin ask load if screenchange event was seen

-- save inv after 10sec for certain win events - UNLESS a recent screen event fired
screensave_count = 0
screensave_timer = hs.timer.delayed.new(10, function()
    if screenload_pending or screensave_count > 900000000 then
        screenload_notif:send()
        print("savewininv INHIBITED "..screensave_count )
        screensave_count = 0
    else
        print("savewininv()")
        screensave_count = 0
        -- savewininv()
    end
end)
-- watch for window add/sub/mov events, and savewininv in 10sec
-- TODO: if screensave_timer count increases too far then trigger a load instead
hs.window.filter.default:subscribe(hs.window.filter.windowCreated  , function(w,a,e) screensave_count=screensave_count+1; print(e..screensave_count.." "..trim(a).." "..w:id()) screensave_timer:start(10) end )
hs.window.filter.default:subscribe(hs.window.filter.windowDestroyed, function(w,a,e) screensave_count=screensave_count+1; print(e..screensave_count.." "..trim(a).." "..w:id()) screensave_timer:start(10) end )
hs.window.filter.default:subscribe(hs.window.filter.windowMoved    , function(w,a,e) screensave_count=screensave_count+1; print(e..screensave_count.." "..trim(a).." "..w:id()) screensave_timer:start(10) end )

-- space inventory {{{
-- https://github.com/asmagill/hs._asm.undocumented.spaces
-- hs.spaces = require("hs._asm.undocumented.spaces")
-- > hs.inspect(hs.spaces.layout() )
-- {
--   ["0A297957-CD40-C16D-3D61-19A3AC3F8E4B"] = { 16, 78 },
--   ["23DB6917-B5E5-9DF4-260E-52B215CFFEF8"] = { 1 },
--   ["387DC755-7473-A7DA-6825-8302929AB06A"] = { 10, 7 },
--   ["F439A5A7-F367-DB70-B9C6-18D284EE9FE2"] = { 9, 5, 133, 134, 135 }
-- }

-- > spaces.screensHaveSeparateSpaces()
-- true

-- > hs.spaces.masks
-- allOSSpaces     11
-- otherOSSpaces   10
-- currentOSSpaces 9
-- otherSpaces     6
-- currentSpaces   5
-- allSpaces       7

-- > hs.spaces.query( hs.spaces.masks.allSpaces )
-- { 135, 134, 133, 78, 16, 10, 9, 7, 5, 1 }
-- > for i,id in ipairs( hs.spaces.query( hs.spaces.masks.allSpaces ) ) do
--     print( i .. ":" .. hs.spaces.spaceName( id ) )
-- end
-- 2020-03-03 12:00:11: 1:42CDCDF7-BB14-4538-807E-6EA35B34D87A
-- 2020-03-03 12:00:11: 2:1431547B-D79C-4CDE-92C1-F2FFE3FB0DB9
-- 2020-03-03 12:00:11: 3:79678888-09D9-450A-8BEC-D4FF70C20723
-- 2020-03-03 12:00:11: 4:00A7D3CC-DF4E-42B8-B91A-575DF58AB690
-- 2020-03-03 12:00:11: 5:767EF4B1-C313-4C37-97BA-D479A7775874
-- 2020-03-03 12:00:11: 6:BC4CDB6A-701B-4C95-B5AA-123E467B2117
-- 2020-03-03 12:00:11: 7:D1E4121B-F7E8-40D5-9975-2BCDD3AF99F2
-- 2020-03-03 12:00:11: 8:381FD10B-486B-4884-AFFA-37E770F531AD
-- 2020-03-03 12:00:11: 9:268A8026-73BD-45C3-B088-58FB53A52309
-- 2020-03-03 12:00:11: 10:

-- > hs. spaces.debug.layout()
-- { {
--     ["Current Space"] = <1>{
--       ManagedSpaceID = 1,
--       id64 = 1,
--       type = 0,
--       uuid = "",
--       wsid = 1
--     },
--     ["Display Identifier"] = "23DB6917-B5E5-9DF4-260E-52B215CFFEF8",
--     Spaces = { <table 1> }
--   }, {
--     ["Current Space"] = <2>{
--       ManagedSpaceID = 10,
--       id64 = 10,
--       type = 0,
--       uuid = "BC4CDB6A-701B-4C95-B5AA-123E467B2117"
--     },
--     ["Display Identifier"] = "387DC755-7473-A7DA-6825-8302929AB06A",
--     Spaces = { <table 2>, {
--         ManagedSpaceID = 7,
--         id64 = 7,
--         type = 0,
--         uuid = "381FD10B-486B-4884-AFFA-37E770F531AD"
--       } }
--   }, {
--     ["Current Space"] = <3>{
--       ManagedSpaceID = 16,
--       id64 = 16,
--       type = 0,
--       uuid = "767EF4B1-C313-4C37-97BA-D479A7775874"
--     },
--     ["Display Identifier"] = "0A297957-CD40-C16D-3D61-19A3AC3F8E4B",
--     Spaces = { <table 3>, {
--         ManagedSpaceID = 78,
--         id64 = 78,
--         type = 0,
--         uuid = "00A7D3CC-DF4E-42B8-B91A-575DF58AB690"
--       } }
--   }, {
--     ["Current Space"] = <4>{
--       ManagedSpaceID = 9,
--       id64 = 9,
--       type = 0,
--       uuid = "D1E4121B-F7E8-40D5-9975-2BCDD3AF99F2"
--     },
--     ["Display Identifier"] = "F439A5A7-F367-DB70-B9C6-18D284EE9FE2",
--     Spaces = { <table 4>, {
--         ManagedSpaceID = 5,
--         id64 = 5,
--         type = 0,
--         uuid = "268A8026-73BD-45C3-B088-58FB53A52309"
--       }, {
--         ManagedSpaceID = 133,
--         id64 = 133,
--         type = 0,
--         uuid = "79678888-09D9-450A-8BEC-D4FF70C20723"
--       }, {
--         ManagedSpaceID = 134,
--         id64 = 134,
--         type = 0,
--         uuid = "1431547B-D79C-4CDE-92C1-F2FFE3FB0DB9"
--       }, {
--         ManagedSpaceID = 135,
--         id64 = 135,
--         type = 0,
--         uuid = "42CDCDF7-BB14-4538-807E-6EA35B34D87A"
--       } }
--   } }

-- !!!!!!! hs.spaces.report() crashes hammerspoon

-- }}}
-- application inventory {{{
-- app watcher - start/stop apps - maybe mojave show up here? not clearly...
--  _appeventtype = { "launching", "launched", "terminated", "hidden", "unhidden", "activated", "deactivated" }
--  hs.application.watcher.new( function( name, type, app )
--      name = name and name or "noname"
--      if type+1 < 6 then  -- ignore activated/deactivated
--          print( "APP EVENT: type=" .. _appeventtype[type+1] .. ", name="..name )
--      end
--  end):start()
-- }}}



-- EXPERIMENTAL
-- canvas playing around {{{
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
-- }}}
-- display screen + window arrangement on canvas {{{
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
    scrlist = hs.fnutils.imap(hs.screen.allScreens(),                  function(s)local f=s:fullFrame();f.color=blu;                  return f;end)
    winlist = hs.fnutils.imap(hs.window.filter.new(true):getWindows(), function(w)local f=w:frame();    f.color=grn; f.text=w:title();return f;end)

    disp_rect( can, scrlist )
    disp_rect( can, winlist )

    can:show()
    hs.timer.doAfter(4,function() can:hide(2) end)
end
-- }}}

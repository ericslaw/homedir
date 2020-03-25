hammerspoon notes+links
    https://www.hammerspoon.org/
    https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations
    http://www.hammerspoon.org/go/

modules {{{
hs          core {{{
    hs.inspect
    hs.printf
    hs.toggleConsole
}}}
console         hs+lua playground
spoons          module mgmt
timer           timing callbacks
settings        persistent state thru reboots
json
logger          in-mem logging
math            floor round etc
task            subproc

::hardware/system::
distribnotif    distributednotifications api - what notifs are avail?  spotify, what else? {{{
    https://stackoverflow.com/questions/30000016/how-to-observe-notifications-from-a-different-application
    com.spotify.client
    com.apple.message
    com.apple.MultitouchSupport
    com.apple.bluetooth
    com.google.Chrome
    com.apple.screencapture
    com.apple.MultitouchSupport.gesture
    ^^ does this break in catalina? https://stackoverflow.com/a/30027772/2135

    what about close/open lid?  IORegisterForSystemPower ?
    imessage?

}}}
plist           resource file read/write
applescript     call applescript (like 'tell application spotify')
osascript
audiodevice     audio in/out device state etc
caffeinate      macos nosleep
usb             connect/disconnect events
network         config,events,wifi,ping
wifi            specific to wifi vs networks
location        geolocation

::keyboard/mouse/track::
hid             capslock state?
hotkey          shortcuts?
keycodes        keymap
eventtap        keyboard(keys,modifiers),mouse(location,buttons,mouseMoved),track(gestures) {{{
    drag
    magnify
    swipe
    rotate
    pressure
}}}

::audio::
sound           play audio
speech          text2speech: hs.speech.new():speak("hello")
noises          audio recog whistle+pop

::windows/screens/spaces::
window          windowmgmt
screen          display layout
spaces          spaces
menubar         menubar menu/icons
geometry        x,y,w,h,aspect,...
grid            screen grid layouts
styledtext      markdown?
image           image capture/manip/generate incl ASCIIimage
canvas          draw onscreen (clock,calendar,pomodoro)
layout          window layout rules
redshift        flux
uielement       sub-windows
tabs            tabify apps
webview         html popup windows

::interact::
alert           onscreen text box
dialog          popup interaction
chooser         popup chooser w/ autocomplete
notify          alert

::apps::
urlevent        handle requests to hammerspoon:// URLs which can then direct actual URLs to specifi browser instances etc
pasteboard      clipboard manip
vox             music player controls
messages        imessage interface
spotify         client

::other::
cricleclock
colorpicker
countdown
micmute
modelmgr?       per-app keybinding?
mousecircle
mirowinmgr
movespaces
winwin
windowhalfsandthirds
windowscreenleftandright

RecursiveBinder sequence key binding



}}}

apple terminology {{{
    display     physical monitors built-in or attached
    desktop     virtual workspace for display
                    may have single-desktop and single-display
                    may have single-desktop and  multi-display      (each display is called a 'screen')
                    may have  multi-desktop and single-display      (each desktop is called a 'space')
                    may have  multi-desktop and  multi-display      (each display 'screen' can have multiple 'spaces')
    screen      visible portion of virtual desktop on physical display
                    primaryScreen - screen with origin at 0,0 - tends to have menubar+dock
                    currentScreen - has window with keyboard focus (readonly) 
    space       switchable desktop on all-displays or per-display
                    syspref / mission / displays have separate spaces
                    fullscreen  special temporary space for fullscreen apps
                    dashboard   special space for displaying widgets - moved to notification overlay panel - removed in catalina
    menubar
    dock
    missioncontrol

}}}
apple key modifiers: cmd,shift,opt/alt,ctrl {{{
https://apple.stackexchange.com/a/181263/1120
https://developer.apple.com/design/human-interface-guidelines/macos/user-interaction/keyboard/
    also says list in order? Control(^), Option(\), Shift(_), Command(#)
    looks like reverse of preferred use:
    # _#
    \# \_#
    ^# ^\# ^_#
    ^\_#
^\# mash (all)
^ # mosh (no opt)
    mish (shIft?)

    KEY     USE             DESCRIPTION
    cmd     main            common commands like open,find,copy,xut,paste,new,tab,close,quit
    shift   common          modify/reverse
    opt     sparingly       advanced - opt+cmd tends to be somewhat drastic - w=close-all-win, 
    ctrl    avoid-alone     extra shortcuts, ctrl-click (=right-click w/out raise?), otherwise avoid
    fn                      keyboard key modifier - expose function keys from action keys, shift-fn-eject = lock?

System Actions
    cmd+space   spotlight launch/search
    cmd+tab     recent app switcher
    ctrl-shift-eject    sleep display

Window Mgmt
    cmd+drag    move window without activate+raise
    cmd+~       next window
    cmd+`

}}}

winmgr ideas {{{
    key up []      move screen|space
    key up +/-     increase/decrease size while accounting for gravity (what about constrained horizontal/vertical?)
    key down arrow - sets orientation/intent
    key up arrow - take action accounting for orientation/intent
        same orient = move or shrink
        opposite orient = move or expand?
        ortho orient = corner
        also sets gravity for this window for possible resize later if hits screen edge
    gravity = nesw - in priority order? matter?
    edge touch matters

    actions are not move/resize but throw/grow

    can window edge matter?
    two tugs away from window breaks free? too complex?
    size matters - canned or ratio size implies goto NEXT size, else cycle back
    window ratio constrants by app?
    windowshade is possible?

winmgr action keystroke and edit history
    https://github.com/andweeb/.hammerspoon/blob/master/ki-config.lua
    https://github.com/scottwhudson/Lunette/
+   lunette uses opt-cmd combo - might be nice alternative to mash ctl-opt-cmd
    https://github.com/scottwhudson/Lunette/blob/master/Source/Lunette.spoon/history.lua
    has history stack? for undo/redo - nice!
    why runs validate? in case move failed?
}}}

hs-config == window resize on screen-edge, window snapping to grid
    https://github.com/mtrpcic/hs-config#window-snapping
window resize/cycling
    https://github.com/S1ngS1ng/HammerSpoon/blob/master/window-management.lua

articles/samples
    https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
    https://www.micsumner.com/focus/how-to-organise-window-viewing-areas-in-mac-os/
    https://msol.io/blog/tech/work-more-efficiently-on-your-mac-for-developers/
    https://wincent.com/wiki/Hammerspoon

    https://medium.com/@_ahmed_ab/crazy-development-environment-on-imac-and-macbook-pro-95a03e74da17
    https://www.reddit.com/r/MacOS/comments/aa4a2i/thoughts_on_the_state_of_macos_automation/
    https://spinscale.de/posts/2019-05-28-creating-a-productive-terminal-environment.html
    https://zzamboni.org/post/my-hammerspoon-configuration-with-commentary/
    https://libraries.io/github/scottcs/dot_hammerspoon
    https://github.com/snowe2010/.hammerspoon

win stuffs
    https://github.com/miromannino/miro-windows-manager
    dragwin? move=cmd+ctrl+drag  resize=cmd+ctrl+shift https://gist.github.com/feifanzhou/05dc353d291f63e103f1c9442fce238e
    dragwin? move=cmd+shift+drag resize=alt+shift+drag  https://gist.github.com/kizzx2/e542fa74b80b7563045a#gistcomment-2023593
    winmgt based on last state: https://gist.github.com/TsingJyujing/d5d4a99b9fb25c1dd16d0ae49699dd8c
    win frame correctness https://github.com/snowe2010/Spoons/blob/master/Source/WindowScreenLeftAndRight.spoon/init.lua#L41
    hammerspoon layout ? https://www.songofcode.com/posts/powerful-hammerspoon/

    miro's winmgr       https://github.com/miromannino/miro-windows-manager/blob/master/MiroWindowsManager.spoon/init.lua
    dillieo's fork      https://github.com/Dillie-O/mir-a-dillieo-winspoon/blob/master/MirADillieOWinSpoon.spoon/init.lua
        adds centering, moving screens - that's all
        
timers
    https://www.hammerspoon.org/docs/hs.timer.html
        waitUntil( function() return true end, function() action end, 1 )
    https://www.hammerspoon.org/docs/hs.timer.delayed.html
        # coalesce events - useful for debounce
        new( delay, function() end )
            :running()              # true if started
            :nextTrigger() = nsec   # get sec til
            :setDelay(delay)        # reset delay
            :start():stop()

keys
    hs modal keymapper https://gist.github.com/dulm/ee5ec47cfd2a71ded0e3841ee04e6ea3
    hs windowmgmt keybinding: https://gist.github.com/thinhunan/fd61b3398edf3a2e74d1761807a2be81
    hotkey per app? modal 
    https://github.com/snowe2010/Spoons/blob/master/Source/ModalMgr.spoon/init.lua
    hotkey per app {{{
++  chrome keystroke cmd-n/t OR ctrl-n/t = new window/tab  how?  syspref does not work
https://github.com/Hammerspoon/hammerspoon/issues/664
    use hs.application.watcher for activate/focus events (beware focus stealing by iterm2!) and enable/disable hotkeys?  maybe just detect on hotkey?
    BUT cannot repeat current hotkey for passthru?
    note: planned in 2015; hs.hotkey.bindForApplication()...

raven 2016/03/29 adds snippet {{{
reloadFxFromRubyMine = hs.hotkey.new('⌘', 'r', function()
      hs.application.launchOrFocus("Firefox.app")
      reloadFxFromRubyMine:disable() -- does not work without this, even though it should
      hs.eventtap.keyStroke({"⌘"}, "r")
  end)

hs.window.filter.new('RubyMine')
    :subscribe(hs.window.filter.windowFocused,function() reloadFxFromRubyMine:enable() end)
    :subscribe(hs.window.filter.windowUnfocused,function() reloadFxFromRubyMine:disable() end)

}}}
but cmsj closed 2017/04/27 (wut?!)


macos key binding
    macos kill-ring register? https://twitter.com/ttscoff/status/1112901323593314305
    http://evantravers.com/articles/2019/04/03/my-keyboard-setup/
        mentions keycastr
    }}}
    remapKey with callbacks? https://gist.github.com/amasho/d47983c4ac5b9e84e73f4d43cd55bf9e
    hs key remap? cant resend same key? https://groups.google.com/forum/#!topic/hammerspoon/yp4AvJr5v7Q
    hs per-app binding? https://groups.google.com/forum/#!msg/hammerspoon/IWG6_tTGv9Y/dGFpURP7AQAJ {{{
bind = hs.hotkey.new({},"key",function()end )
hs.application.watcher.new(function(nam,typ,obj)
    if nam == "iTerm2" then
        if typ == hs.application.watcher.activated then
            bind:enable()
        elseif typ == hs.application.watcher.deactivated or hs.application.watcher.terminated then
            bind:disable()
        end
    end
end):start()
    }}}

spoons
    https://github.com/ashfinal/awesome-hammerspoon/wiki/The-built-in-Spoons
        CircleClock
        CountDown - NICE
        ksheet?
        speedmenu?
        timeflow?
        winwin
        movespaces requires .so file from undocumented.spaces module

pomodoro
        pomodoor.lua    like CountDown but top of screen
        http://evantravers.com/articles/2018/10/02/pomodoro-in-hammerspoon/
        https://github.com/snowe2010/.hammerspoon/blob/master/pomodoor.lua
        https://github.com/snowe2010/.hammerspoon/blob/master/bar.lua
        https://github.com/evantravers/hammerspoon/blob/master/pomodoro.lua
        https://github.com/atsepkov/hammerspoon-config/blob/master/modules/pomodoor.lua
        pomodoro widgets bar + pomodoor
        https://github.com/ztomer/.hammerspoon

audiodevice
    hammerspoon stop audio dev from being hdmi {{{
hs.audiodevice.watcher.setCallback()
https://www.hammerspoon.org/docs/hs.audiodevice.watcher.html
atap = hs.audiodevice.watcher.setCallback()
    per device?


function callbackAudev(uid,event,scope,element)
    print( "audev: "..uid.." "..event.." "..scope.." "..element)
end
function watchAudev(audev)
    audev:watcherStop()
    audev:watcherCallback(nil)
    audev:watcherCallback(callbackAudev)
    audev:watcherStart()
end
function watchAudevAll()
    local audevlist = hs.audiodevice.allDevices()
    for i=1, #devlist do
        watchAudev(audevlist[i])
    end
end




--or--
function adwCallback(ev)
    print( "adw event ".. ev)
end
hs.audiodevice.watcher.setCallback(nil)
hs.audiodevice.watcher.setCallback(adwCallback)
hs.audiodevice.watcher.start()

2020-01-24 10:18:51: adw event dev#     # add/rm audio device
2020-01-24 10:18:51: adw event dIn      # def input changed
2020-01-24 10:18:51: adw event dOut     # def output changed
2020-01-24 10:18:51: adw event sOut     # soundeffects output changed

table.sort
    local olist = hs.audiodevice.allOutputDevices()

2020-01-24 14:14:46:    -,defo, -,out,nojack,    -,    -,  ni, 49%,   -,USB         ,Dell USB Audio  ,AppleUSBAudioEngine:DisplayLink:Dell Universal Dock D6000:1708154742:3
2020-01-24 14:14:46:    -,   -,in,out,nojack,    -,    -,100%,100%,   -,USB         ,Arctis 7 Chat   ,AppleUSBAudioEngine:SteelSeries :SteelSeries Arctis 7:14122000:1,2
2020-01-24 14:14:46:    -,   -, -,out,nojack,    -,    -,  ni,100%,   -,USB         ,Arctis 7 Game   ,AppleUSBAudioEngine:SteelSeries :SteelSeries Arctis 7:14122000:4
2020-01-24 14:14:46:    -,   -, -,out,nojack,    -,    -,  ni, 44%,   -,Built-in    ,MacBook Pro Speakers,BuiltInSpeakerDevice
2020-01-24 14:14:46:    -,   -,in,out,nojack,    -,    -,100%,100%,   -,Virtual     ,ZoomAudioDevice ,zoom.us.zoomaudiodevice.001
2020-01-24 14:14:46:    -,   -, -,out,nojack,    -,    -,  ni,  no,   -,DisplayPort ,DisplayPort     ,AppleGFXHDAEngineOutputDP:0:{AC10-A0AA-3133524C}

2020-01-24 14:14:46: defi,   -,in,  -,nojack,    -,    -, 94%,  no,   -,USB         ,HD Webcam C615  ,AppleUSBAudioEngine:Unknown Manufacturer:HD Webcam C615:57647350:1
2020-01-24 14:14:46:    -,   -,in,  -,nojack,    -,    -,100%,  no,   -,Built-in    ,MacBook Pro Microphone,BuiltInMicrophoneDevice
2020-01-24 14:14:46:    -,   -,in,  -,nojack,    -,    -, 73%,  no,   -,USB         ,Dell USB Audio  ,AppleUSBAudioEngine:DisplayLink:Dell Universal Dock D6000:1708154742:4

    }}}
    csv wifi prefs? https://spinscale.de/posts/2016-11-08-creating-a-productive-osx-environment-hammerspoon.html

spotify
    spotify album image research {{{
https://developer.spotify.com/documentation/web-api/reference/tracks/get-track/
get 
curl -X GET "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl" -H "Authorization: Bearer {your access token}"
    http://www.hammerspoon.org/docs/hs.image.html#imageFromURL
        imageFromURL wont work, need auth header
    http://www.hammerspoon.org/docs/hs.http.html#doRequest
    http://www.hammerspoon.org/docs/hs.http.html#doAsyncRequest
        hs.http.doAsyncRequest(url, "GET", nil, {"authorization":"bearer "..token}, callback, "returnCacheOrLoad")

        lets you set headers - has (a)sync and cache options

    spotify:track:0UnJRR4wfPjqEPNxIRKnc3

...

    }}}

spaces
    hs https://github.com/asmagill/hs._asm.undocumented.spaces {{{
xcode already installed? did not have to re-download.
make install
lots of warnings but no errors
creates .so file, stuffs in .hammerspoon/hs/_asm/undocumented but with verbose subdir
ln -s hs._asm.undocumented.spaces/ ~/.hammerspoon/hs/_asm/undocumented/spaces
now it works in console with; spaces = require("hs._asm.undocumented.spaces")

> hs.inspect(spaces.layout())
{
  ["0A297957-CD40-C16D-3D61-19A3AC3F8E4B"] = { 147 },
  ["23DB6917-B5E5-9DF4-260E-52B215CFFEF8"] = { 1 },
  ["387DC755-7473-A7DA-6825-8302929AB06A"] = { 149 },
  ["F439A5A7-F367-DB70-B9C6-18D284EE9FE2"] = { 148 }
}


now module MoveSpaces.spoon would work, but presumes directional relative to current active screen.
I want to move entire screens to other spaces (and back)

some other day...
what events to listen to for display disconnect/reconnect ?
    }}}
    session control?  kinda like a suite of windows as a group to show/hide rotate thru?
    https://github.com/ztomer/.hammerspoon/tree/master/sessions-control
    space moving
    https://github.com/Hammerspoon/hammerspoon/issues/823
    2015 hack to move a space?
    https://github.com/Hammerspoon/hammerspoon/issues/235
    https://stackoverflow.com/questions/46818712/using-hammerspoon-and-the-spaces-module-to-move-window-to-new-space
        concise move-win-to-space
    https://github.com/snowe2010/Spoons/blob/master/Source/MoveSpaces.spoon/init.lua

watcher
    https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/window/layout.lua#L746
    hs watchers {{{
http://www.hammerspoon.org/docs/hs.screen.watcher.html      screen layout changes; position, add/del
http://www.hammerspoon.org/docs/hs.spaces.watcher.html      space change? like moved to new active space?

function spacehand(arg) print("spacehand") print(arg) end
spacewatch = hs.spaces.watcher.new(spacehand)
spacewatch:start()
-- ctrl-> causes spacehand(-1), so have to figure out what changed.
    }}}
    hs watchers - screen and winfilter {{{

local screenlist = hs.screen.allScreens()
local screenkeys = {}
for key in pairs(scrlist) do table.insert(scrkeys,key) end
table.sort(scrkeys)
for idx,item in ipairs(scrkeys) do print(item)

hs.screen:localToAbsolute(fullFrame) 

:::screen:::
    for i,scr in ipairs(hs.screen.allScreens()) do
        local name,id,uuid,frame = scr:name(), scr:id(), scr:getUUID(), scr:fullFrame()
        print(string.format("screen:%10s:%5s:%5d,%5d@%4dx%4d:%11s",id,uuid,frame.x,frame.y,frame.w,frame.h,name))
    end
    screen can be main(focus) or primary (menubar+dock)
:::window:::
#   hs.logger.defaultLogLevel
#   hs.logger.setGlobalLogLevel('verbose')        -- # nothing=0 error=1 warning=2 info=3 debug=4 verbose=5
    winfilt = hs.window.filter.new(true)
    winfilt = hs.window.filter.new(true,"winfilt","verbose")
    winfilt:setFilters({ default = {} )
    winfilt:pause():resume()
#   winfilt:subscribe(event,function()end)
#   winfilt:subscribe({event1=func1,...})
    winfilt:switchedToSpace(function(space) print("switch space "..space);end)


    winfilt = hs.window.filter.new():rejectApp("Hammerspoon")
    winfilt:subscribe({
        windowCreated       = function() print("wf:create");disp_all();end,
        windowDestroyed     = function() print("wf:destroy");disp_all();end,
        windowMoved         = function() print("wf:moved");disp_all();end,
    })
--      windowTitleChanged  = function() print("wf:title");disp_all();end,

    window events {{{

windowAllowed windowRejected windowsChanged

windowCreated windowDestroyed
windowMoved

windowHidden windowUnhidden
windowMinimized windowUnminimized

#windowFullscreened windowUnfullscreened
#windowFocused windowUnfocused
#windowInCurrentSpace windowNotInCurrentSpace


windowVisible windowNotVisible
windowOnScreen windowNotOnScreen

implies window states are:
    role                AXStandardWindow AXDialog AXSystemDialog 
    hasTitlebar
    active
    visible onscreen fullscreen hidden minimized
    focused


    }}}
    window state {{{
setFrameCorrectness = true # run additional checks
:screen()
:application()
:frame()
:role()
:subrole()
:title()
:tabCount()
    }}}

    winfilt:getWindows()
    winfilt:unsubscribeAll(function()end)

hud_timer = hs.timer.delayed(2,function()disp_all() end)

:::app:::
:::audiodevice:::



dump screen info
    for i,scr in ipairs(hs.screen.allScreens()) do
        local name,id,uuid,frame = scr:name(), scr:id(), scr:getUUID(), scr:fullFrame()
        print(string.format("screen:%10s:%5s:%5d,%5d@%4dx%4d:%11s",id,uuid,frame.x,frame.y,frame.w,frame.h,name))
    end
        id          uuid                                x       y   w   h       name
screen:  69734409:F439A5A7-F367-DB70-B9C6-18D284EE9FE2:-1680,  870@1680x1050:  Color LCD
screen: 725361613:23DB6917-B5E5-9DF4-260E-52B215CFFEF8:    0,    0@1200x1920: DELL U2413        # origin / primary because 0,0
screen: 724072664:387DC755-7473-A7DA-6825-8302929AB06A: 1200,    0@3440x1440:DELL U3415W        
screen: 725362638:0A297957-CD40-C16D-3D61-19A3AC3F8E4B: 4640,    0@1200x1920: DELL U2413

function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end
maxw = math.min(table.unpack(map( function(scr) return scr:fullFrame().x;end, hs.screen.allScreens() ))) +
       math.max(table.unpack(map( function(scr) return scr:fullFrame().x+scr:fullFrame().w;end, hs.screen.allScreens() )))
maxh = math.min(table.unpack(map( function(scr) return scr:fullFrame().y;end, hs.screen.allScreens() ))) +
       math.max(table.unpack(map( function(scr) return scr:fullFrame().y+scr:fullFrame().h;end, hs.screen.allScreens() )))

scale=0.1

--      print(
--  --      string.format("%6s %6s %6sx%6s",of.x,of.y,of.w,of.h) ..
--   --     " => " ..
--          string.format("%6s %6s %6sx%6s",nf.x,nf.y,nf.w,nf.h)
--      )

WORKS {{{
> function disp_rect( rectlist )
    local dstscr = hs.screen:primaryScreen():toEast()
    local dstctr = dstscr:fullFrame().center
    local scale = 0.1

    local can = hs.canvas.new( dstscr:fullFrame():scale(0.5):floor() ):show()
    for i,of in ipairs(rectlist) do
        local nf = hs.geometry.rect(
            of.x * scale + dstctr.x*scale,  -- bug here for sure
            of.y * scale + dstctr.y*scale,  -- bug here for sure
            of.w * scale,
            of.h * scale
        ):floor()
--      print(
--  --      string.format("%6s %6s %6sx%6s",of.x,of.y,of.w,of.h) ..
--   --     " => " ..
--          string.format("%6s %6s %6sx%6s",nf.x,nf.y,nf.w,nf.h)
--      )
        can:insertElement({ type = "rectangle", fillColor = { alpha = 0.5, green=0.5 }, frame = {x=nf.x,y=nf.y,w=nf.w,h=nf.h} })
    end
    can:delete(5)
end


> disp_rect( map(function(s)return s:fullFrame();end,hs.screen.allScreens()) )


> disp_rect( map(function(s)return s:frame();end,hs.window.filter.new(true):getWindows()) )

}}}

function disp_rect( can, rectlist )
    local dstctr = hs.geometry.rect( can:frame() ).center
    local scale = 0.1

    for i,of in ipairs(rectlist) do
        local nf = hs.geometry.rect(
            of.x * scale + dstctr.x*scale,  -- bug here for sure
            of.y * scale + dstctr.y*scale,  -- bug here for sure
            of.w * scale,
            of.h * scale
        ):floor()
        can:insertElement({ type = "rectangle", fillColor = { alpha = 0.5, green=0.5 }, frame = {x=nf.x,y=nf.y,w=nf.w,h=nf.h} })
    end
end

function wut()
    local dstscr = hs.screen:primaryScreen():toEast()
    local can = hs.canvas.new( dstscr:fullFrame():scale(0.5):floor() ):show()

    scrlist = map(function(s)return s:fullFrame();end,hs.screen.allScreens()) 
    winlist = map(function(s)return s:frame();end,hs.window.filter.new(true):getWindows())

    disp_rect( can, scrlist )
    disp_rect( can, winlist )

    can:delete(5)
end


disp_rect( hs.screen.allScreens() )
# doh! could have simply used the transformation matrix!


of = hs.screen.primaryScreen():toEast():fullFrame()
nf = hs.geometry.copy(of):
:scale(0.1):floor()
nf.xy=frame.x//2,frame.y//2


unitrect is % x,y,w,h of one frame within another



map (
map( function(scr) return scr:fullFrame(); end, hs.screen.allScreens() )
for i,scr in ipairs(hs.screen.allScreens()) do
    dstscr:absoluteToLocal( scr:fullFrame() ):move(dstctr):scale()
end

move scale




drawing screens:
fr = hs.screen.mainScreen():fullFrame()
frx,fry = fr.w//2,fr.h//2
can = hs.canvas.new({x=10,y=10,w=800,h=800,scale=0.1})



# primary - screen with menubar + dock - origin
# main - where focus is now (so new windows can appear there?)

draw on center of main screen - the screen layouts
 
    }}}
    hs.window.filter as alt to hs.app.watcher
    sub-window watcher
        http://www.hammerspoon.org/docs/hs.uielement.watcher.html
        can watch for window move/resize/min/unmin
        can watch focus changes (like iterm2 stole focus?)
        function uihand(arg) print("uihand") print(arg) end
        uiw=hs.uielement.newWatcher(uihand)
        uiw=hs.uielement.newWatcher( function uihand(arg) print("uihand") print(arg) end )
        uiw=hs.uielement.watcher.new( function (arg) print("uihand") print(arg) end )
        uie=hs.uielement.watcher
        hs.uielement.watcher:start({ uie.windowCreated, uie.windowMoved, uie.windowResized })
        github example: https://gist.github.com/tmandry/a5b1ab6d6ea012c1e8c5
        another example in use: https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/tabs/init.lua
    hs windowTracker in 80lines: https://gist.github.com/tmandry/a5b1ab6d6ea012c1e8c5
    hs screenTracker? https://gist.github.com/cleverdevil/fd3e5f9eea3215547ea2c6492c0d3ee0  just hs.screen.watcher.new()
    https://github.com/Hammerspoon/hammerspoon/issues/2291


timers
    https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/modules/worktime.lua
    https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/modules/timer.lua

    hammerspoon timer + dialog https://www.hammerspoon.org/docs/hs.dialog.html#textPrompt https://www.hammerspoon.org/docs/hs.timer.html#doEvery
    http://www.hcs.harvard.edu/~jrus/Site/cocoa-text.html

    hammerspoon tiling winmgr {{{
vs amethyst
    https://www.slant.co/versus/1695/1727/~hammerspoon_vs_amethyst
        amethyst ported from objc to swift
    https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
        moving windows about with hs.layout
    https://hn.svelte.dev/item/19314999
        other tiling winmgrs listed
    https://medium.com/ryan-hanson/window-management-on-macos-1fadb3d1d84a
        multitouch rectangle
    https://www.slant.co/topics/526/~best-window-manager-for-mac

    https://thesweetsetup.com/apps-were-trying-alternative-window-managers-for-macos/
    https://medium.com/@douglasshooker/tiling-your-windows-on-osx-92ac20453560


other winmgrs
?   hswm            https://github.com/NTT123/hswm              # tiling hammerspoon w/ multi-space hack - derived from chunkwm
    hhtwm           https://github.com/szymonkaliski/hhtwm      # tiling hammerspoon MODULE, used by hswm or can use direct
    yabai           https://github.com/koekeishiya/yabai        # winmgr requires disable integrityprot! NOPE!
    chunkwm         https://github.com/koekeishiya/chunkwm      # tiling winmgr - ABANDONWARE
?   amethyst        https://ianyh.com/amethyst/                 # tiling winmgr - still actively developed


+++ hammerspoon     fork of mjolnir
    mjolnir         https://github.com/mjolnirapp/mjolnir       #   ABANDONWARE 2014
    zephyros        https://github.com/mishoo/zephyros          #   ABANDONWARE? might be a fork
    phoenix         https://github.com/kasper/phoenix           # js scriptable, brew installable
    hydra           https://github.com/jhgg/hydra               # abandonware? 5y old
+   slate           https://github.com/jigish/slate             # like mjolnir but all-in-one vs modularized

    layauto?        https://layautoapp.com/                     # $10 like stay
+   stay            https://cordlessdog.com/stay/               # $15 restore windows on monitors once reconnected

    rectangle       https://rectangleapp.com/   https://github.com/rxhanson/Rectangle
    multitouch      https://multitouch.app/     # $8
    magnet          http://magnet.crowdcafe.com/                # $2 size/move window by drag to screen edges
    bettertouchtool ?
    bettersnaptool  https://apps.apple.com/us/app/id417375580
    veeer           https://veeer.io/                           # ?
    divvy           https://apps.apple.com/us/app/id413857545   # $14
    cinch           http://www.irradiatedsoftware.com/cinch/    # $7    size/move window by drag to screen edges
    sizeup          http://www.irradiatedsoftware.com/sizeup/   # $13   size/move window w/ shortcuts
    tuck            http://www.irradiatedsoftware.com/tuck/     # $7    hide windows just-barely-offscreen, hover to reveal
    moom            https://manytricks.com/moom/                # $10   simple size/move window, layouts + grid options
    spectacle       https://www.spectacleapp.com/               #       abandonware

    other tools
    skhd            https://github.com/koekeishiya/skhd         # simple hotkey daemon for keyboard shortcuts
    bartender       https://www.macbartender.com/               # $15   org menubar icons?
    karabiner       https://pqrs.org/osx/karabiner/             # key remapper
    witch           https://manytricks.com/witch/               # app switcher
    shiftit         https://github.com/fikovnik/ShiftIt         # abandonware

dash        lang doc ref tool $30 nope!
sketch      visio for macos? $99 nope!

    }}}


winmgr
    I'd love windows to 'remember' edge stickiness so they can flow into alt resolution spaces
    sway?  tiling wm?

url dispatcher - intercept opening of URLs - direct to specific browsers (or apps)  ?
    hs url dispatcher example: https://gist.github.com/jellea/95fbff7e8fd820b78f18250d57ace1b9

scheduled notifs
    hs scheduled notifications {{{
can crontabs access my display?
can lua calc date stuffs?
    https://www.lua.org/pil/22.1.html
    epoch = os.time()

    print( os.date("%Y/%m/%d-%H:%M:%S",epoch))

local dat = os.date("*t")

ival = 300
next_ival = (os.time()+ival)//ival * ival
print( os.date("%Y/%m/%d-%H:%M:%S",next_ival))

notify shows:
    [icon] [boldtitle]
    [subtitle]
    [info]

hs.notify.new(
    setIdImage = img
    title
    subTitle
    informativeText = 
    withDrawAfter = nsec
):schedule()

    hs.notify.activationTypes

sounds
    020-02-25 15:02:42: -- Loading extension: sound
    { "Submarine", "Ping", "Purr", "Hero", "Funk", "Pop", "Basso", "Sosumi", "Glass", "Blow", "Bottle", "Frog", "Tink", "Morse" }
    for nm in hs.sound.systemSounds() do hs.sound.getByName(nm):play() end
    for i,nm in ipairs(nmlist) do print(nm) end

now = os.time()
for i,nm in ipairs(hs.sound.systemSounds()) do
    local s = hs.sound.getBuyName(nm)
    now = now + s:duration()
end
# but all play at once!

for hr=9,18 do
    hs.timer.doAt(hr..":00", function()
        hs.notify.new(
            setIdImage = img_clock,
            title =
            subTitle =
            informativeText = "
            withDrawAfter = 20
        ):schedule()
    end)
end

chime_timer = doEvery( 300,  )

hs.notify.new({
        setIdImage = img_clock,
        title = "chime",
        subTitle = "what time is it?",
        informativeText = "what are you doing",withdrawAfter=0
}):send()


hs.alert("string", {atScreenEdge=1,strokeColor={white=0},fillColor={white=1},textColor={white=0}},"forever" )
hs.alert.closeAll()


        
actionButton
actionButtonTitle
#otherButtonTitle
:responsePlaceholder("notes")
replyButton
otherButton

    }}}


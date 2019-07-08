-- SysMute
-- hammerspoon Spoon module to control syskey mute

local obj={}
obj.__index = obj
obj.name = "SysMute"
obj.author = "Eric Law"
obj.version = "0.1"
obj.homepage = "http://"
obj.license = "license"


obj._state = false           -- true=muted, false=unmuted
function obj:state(value)   -- getset the value {{{
    local last = obj._state
    if value ~= nil then
        obj._state = value
    end
    return last
end -- }}}
-- function obj:sync()         -- sync state with current device?
function obj:mute()         -- toggle state {{{
    if obj:state() then
        obj:state(true)
    end
end -- }}}
function obj:unmute()       -- toggle state {{{
    if obj:state() then
        obj:state(false)
    end
end -- }}}
function obj:toggle()       -- toggle state {{{
    if obj:state() then
        obj:state(false)
    else
        obj:state(true)
    end
end -- }}}
function obj:pressmute()    -- press mute programmatially {{{
    hs.eventtap.event.newSystemKeyEvent("MUTE",true):post()
    hs.eventtap.event.newSystemKeyEvent("MUTE",false):post()
end -- }}}

-- start/stop watch for mute keypress events and update state accordingly
function obj:start()        -- {{{
end -- }}}
function obj:stop()         -- {{{
end -- }}}

-- note: mute key generates event for hs.audiodevice:watcherCallback() ONLY IF UNABLE TO MUTE THE DEVICE!
if able to mute the device, does so WITHOUT EVENT

return obj

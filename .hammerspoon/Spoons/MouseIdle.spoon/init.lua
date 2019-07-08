-- MouseTrack
-- hammerspoon Spoon module to track mouse movement until idle
-- TODO: rename mouseidle
-- TODO: separate non-click-thru from mouseidle
-- TODO: init w/ config
-- TODO: auto-cancel tracking on certain events (like 14? or mouse clicks?)
-- TODO: only invoke simuclick on keypress while hovering over non-frontmost-app
-- TODO: track historical focused window (or text area within a window?)
-- TODO: auto-detect when simclick raises context menu and auto-disable those apps

local obj={}
obj.__index = obj
obj.name = "MouseTrack"
obj.author = "Eric Law"
obj.version = "0.1"
obj.homepage = "http://"
obj.license = "license"

-- TODO: make this local again
obj._et=hs.eventtap.event.types;
obj._ep=hs.eventtap.event.properties;

obj._eventlist = {
    obj._et.NSSystemDefined, -- 14   switching click to focus? does this auto-cancel t
    obj._et.mouseMoved       --  5
}
function obj:_eventshow(e)
    if e:getType() == obj._et.mouseMoved then
        flg=e:rawFlags() & 0xdffffeff;
        loc=e:location();
        print( "moved:"
            .. " ts=" .. e:timestamp()
            .. " type=" .. e:getType()
            .. " sub="  .. e:getProperty(obj._ep.mouseEventSubtype)
            .. " seq="  .. e:getProperty(obj._ep.mouseEventNumber)
            .. " loc="  .. loc.x .. "," .. loc.y
            .. " del="  .. e:getProperty(obj._ep.mouseEventDeltaX) .. "," ..  e:getProperty(obj._ep.mouseEventDeltaY)
            .. " clk="  .. e:getProperty(obj._ep.mouseEventClickState)
            .. " btn="  .. e:getProperty(obj._ep.mouseEventButtonNumber)
            .. " flg="  .. flg
--          .. " raw="  .. hs.inspect(e:getRawEventData())
        );
    end
end
function obj:_winshow(w)
    if w:id() then
        print( "window:"
            .. " scr="   .. w:screen():position()
    --      .. " frame=" .. hs.inspect( w:frame())
    --      .. " std="   .. hs.inspect( w:isStandard())
    --      .. " role="  .. w:role()
            .. " app="   .. hs.inspect( w:application())
            .. " id="    .. w:id()
        );
    end
end
function obj:_findwin(args)
    local cursor = hs.geometry(args)
    local winlist = hs.window.visibleWindows()
    local match;
    for i=1,#winlist do
        local win=winlist[i];
        if cursor:inside(win:frame()) then
            match = win;
            return win;
        end
    end
    if match then
        obj:_winshow(win)
    else
        print("no match");
    end
    return nil;
end

obj.mouseidle = 0.3;
obj._mousemove = hs.eventtap.event.newEvent();   -- global to hold last mousemove event - to be used once idle
obj._mousetimer = hs.timer.delayed.new(          -- global delay timer to trigger when mouse goes idle
    obj.mouseidle,
    function()
        if obj._mousemove:getType() == obj._et.mouseMoved then
            print("mouse went idle after move");
            local win = obj:_findwin(obj._mousemove:location());
            local app = win:application();
            if not app:isFrontmost() then
                print("not active: " .. win:title());
                local appname = app:name();
                local include = { '' };
                if not string.match(appname,exclude) then
                    hs.eventtap.event.newMouseEvent(obj._et.leftMouseDown,obj._mousemove:location(),{ctrl=1,alt=1}):post();
                else
                    print "skipping $appname";
                end
            end
            print(app);
        else
            print("mouse went idle after OTHER");
        end
--      obj:_eventshow(obj._mousemove)
    end
);
obj._mousetap = hs.eventtap.new(
    obj._eventlist,
    function(e)
        obj._mousemove = e;
        if e:getType() == obj._et.mouseMoved then
        --  obj:_eventshow(e);
            if not obj._mousetimer:running() then
                obj._mousetimer:start();
            end
            obj._mousetimer:setDelay(obj.mouseidle);
        end
    end
)

obj._mousetap:start();
obj._mousetap:stop();

function obj:init() print("loaded mouseidle"); end
function obj:start() obj._mousetap:start(); end
function obj:stop() obj._mousetap:stop(); end

return obj

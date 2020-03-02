-- MouseTrack
-- hammerspoon Spoon module to track mouse movement until idle
-- TODO: separate non-click-thru from mouseidle - ie: callback function with last mouse event
-- TODO: init w/ config
-- TODO: auto-cancel tracking on certain events (like 14? or mouse clicks? escape key?)
-- TODO: only invoke simuclick on keypress while hovering over non-frontmost-app
-- TODO: track historical focused window (or text area within a window?) so when activating that app, focus is where is was
--       ie: slack focus remains the message window, chrome remains some form on the page vs location bar
-- TODO: auto-detect when simclick raises context menu and auto-disable those apps
--
-- example of use:
-- hs.loadSpoon("MouseIdle")
-- spoon.MouseIdle:start()          -- recommend trying in console first
-- spoon.MouseIdle:stop()          -- recommend trying in console first

local obj={}
obj.__index = obj
obj.name = "MouseIdle"
obj.author = "Eric Law"
obj.version = "0.11"
obj.homepage = "http://"
obj.license = "license"

-- TODO: make this local again (because are just convenience references, not state in module
obj._et=hs.eventtap.event.types;
obj._ep=hs.eventtap.event.properties;

-- event types to listen for
obj._eventlist = {
    obj._et.mouseMoved,      --  5  mouse move event - obviously needed
    obj._et.NSSystemDefined  -- 14  switching click to focus? does this auto-cancel ? dunno why this needed
}
function obj:_eventshow(e)
    if e:getType() == obj._et.mouseMoved then
        flg=e:rawFlags() & 0xdffffeff;
        loc=e:location();
        print( "moved:"
            .. " ts="   .. e:timestamp()
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
-- what interesting states can a window be in? (or not)
-- focused front visible main allscreens fullscreen zoom minimized hidden?
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
    local winlist = hs.window.orderedWindows()      -- must be ordered TODO: pickup special windows like hs console!
    for i=1,#winlist do
        local win=winlist[i];
        if cursor:inside(win:frame()) then
            return win;
        end
    end
    -- will likely never get here, as Finder owns desktop and HAS a window but it has no 'id'
    print("no match");
--- obj:_winshow(win);
    return nil;
end

obj.mouseidle = 0.2;
obj._mousemove = hs.eventtap.event.newEvent();   -- define global to hold last mousemove event - to be used once idle
obj._mousetimer = hs.timer.delayed.new(          -- define global delay timer to trigger when mouse goes idle
    obj.mouseidle,          -- seconds between calling function  
    function()
        if obj._mousemove:getType() == obj._et.mouseMoved then
--          print("mouse went idle after move");
            -- TODO: callback goes here with mousemove event as param

            local win = obj:_findwin(obj._mousemove:location());
            if win and win:application() and not win:application():isFrontmost() then
                local app = win:application();
                print("");
                print("idleover " .. app:name() .. "|" .. win:title());
                local appname = app:name();
                local exclude = 'finder';   -- pattern to avoid simu-click on
                local include = '';         -- exceptions to exclude above only (does not invoke auto-exclude)

                -- almost perl regex - use % instead of \
                local use_app_nop       = 'iTerm2|Zoom';
                local use_app_simuclick = 'Google Chrome';
                local use_app_click     = '';
                local use_app_activate  = '.*';

                -- may want to exclude certain apps from getting sumi-click (cmd-click which does NOT raise)
                if string.len(appname) then
                    if string.len(use_app_nop)>0 and string.match(appname,use_app_nop) then
                        print("use_nop   " .. appname);
                    elseif string.len(use_app_simuclick)>0 and string.match(appname,use_app_simuclick) then
                        print("SIMUCLICK " .. appname);
                        hs.eventtap.event.newMouseEvent(
                            obj._et.leftMouseDown,
                            obj._mousemove:location(),
                            {ctrl=1,alt=1}
                        ):post();
                    elseif string.len(use_app_click)>0 and string.match(appname,use_app_click) then
                        print("CLICK     " .. appname);
                        hs.eventtap.event.newMouseEvent(
                            obj._et.leftMouseDown,
                            obj._mousemove:location(),
                            {}
                        ):post();
                    elseif string.len(use_app_activate)>0 and string.match(appname,use_app_activate) then
                        print("ACTIVATE  " .. appname);
                        app:activate();     -- activate ALL windows?
                    else
                        print("noaction? " .. appname);
                    end
                else
                    print("skipping NOAPPNAME " .. obj:_winshow(win) );
                end
            end
--          print(app);
        else
            print("mouse went idle after OTHER: " .. obj._mousemove:getType() );
            obj:_eventshow();
        end
--      obj:_eventshow(obj._mousemove)  -- debug - show mousemove event
    end
);

-- listen for move (and other) events, calling function for each
obj._mousetap = hs.eventtap.new(
    obj._eventlist,
    function(e)
        obj._mousemove = e;                         -- save event for later (is this increasing mem footprint?)
        if e:getType() == obj._et.mouseMoved then
        --  obj:_eventshow(e);
            -- if timer was not in use then start it now
            if not obj._mousetimer:running() then   
                obj._mousetimer:start();
            end
            -- change next trigger time out N seconds from now
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

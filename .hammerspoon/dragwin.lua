-- https://gist.githubusercontent.com/feifanzhou/05dc353d291f63e103f1c9442fce238e/raw/a50a1c937798020465ed17834f8f959543fbae98/hammerspoon%2520%25E2%2580%2594%2520init.lua
-- Inspired by Linux alt-drag or Better Touch Tools move/resize functionality
-- from https://gist.github.com/kizzx2/e542fa74b80b7563045a#gistcomment-2023593
-- Command-Ctrl-move: move window under mouse
-- Command-Control-Shift-move: resize window under mouse
function get_window_under_mouse()
   local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
   local my_screen = hs.mouse.getCurrentScreen()
   return hs.fnutils.find(hs.window.orderedWindows(), function(w)
                             return my_screen == w:screen() and
                                w:isStandard() and
                                (not w:isFullScreen()) and
                                my_pos:inside(w:frame())
   end)
end

dragging = {}                   -- global variable to hold the dragging/resizing state

drag_event = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(e)
      if not dragging then return nil end
      if dragging.mode==3 then -- just move
         local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
         local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
         dragging.win:move({dx, dy}, nil, false, 0)
      else -- resize
         local pos=hs.mouse.getAbsolutePosition()
         local w1 = dragging.size.w + (pos.x-dragging.off.x)
         local h1 = dragging.size.h + (pos.y-dragging.off.y)
         dragging.win:setSize(w1, h1)
      end
end)

flags_event = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
      local flags = e:getFlags()
      local mode=(flags.shift and 1 or 0) + (flags.ctrl and 2 or 0) + (flags.alt and 4 or 0)
      if mode==3 or mode==5 then -- valid modes
         if dragging then
            if dragging.mode == mode then return nil end -- already working
         else
            -- only update window if we hadn't started dragging/resizing already
            dragging={win = get_window_under_mouse()}
            if not dragging.win then -- no good window
               dragging=nil
               return nil
            end
         end
         dragging.mode = mode   -- 3=drag, 5=resize
         if mode==5 then
            dragging.off=hs.mouse.getAbsolutePosition()
            dragging.size=dragging.win:size()
         end
         drag_event:start()
      else                      -- not a valid mode
         if dragging then
            drag_event:stop()
            dragging = nil
         end
      end
      return nil
end)
flags_event:start()

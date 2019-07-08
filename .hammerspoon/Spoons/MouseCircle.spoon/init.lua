--- === MouseCircle ===
---
--- Draws a circle around the mouse pointer when a hotkey is pressed

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MouseCircle"
obj.version = "1.0"
obj.author = "Chris Jones <cmsj@tenshu.net>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.circle = nil
obj.timer = nil
obj.hotkey = nil

--- MouseCircle.color
--- Variable
--- An `hs.drawing.color` table defining the colour of the circle. Defaults to red.
obj.color = nil

--- MouseCircle:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for MouseCircle
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * show - This will cause the mouse circle to be drawn
function obj:bindHotkeys(mapping)
    if (self.hotkey) then
        self.hotkey:delete()
    end
    local showMods = mapping["show"][1]
    local showKey = mapping["show"][2]
    self.hotkey = hs.hotkey.bind(showMods, showKey, function() self:show() end)

    return self
end

--- MouseCircle:show()
--- Method
--- Draws a circle around the mouse
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:show()
    circle = self.circle
    timer = self.timer

    if circle then
        circle:delete()
        if timer then
            timer:stop()
        end
    end

    mousepoint = hs.mouse.getAbsolutePosition()

    local color = nil
    if (self.color) then
        color = self.color
    else
        color = {["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1}
    end
    local diam = 256;
    circle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-diam/2, mousepoint.y-diam/2, diam, diam))
    circle:setStrokeColor(color)
    circle:setFill(false)
    circle:setStrokeWidth(50)
    circle:bringToFront(true)
    circle:show(0.25)
    self.circle = circle

    self.timer = hs.timer.doAfter(1, function()
        self.circle:hide(0.25)
        hs.timer.doAfter(0.6, function() self.circle:delete() end)
    end)

    return self
end

return obj

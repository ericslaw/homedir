-- Copyright (c) 2019 Sean Patterson
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this
-- software and associated documentation files (the "Software"), to deal in the Software
-- without restriction, including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

--- === Mir-a-Dillie-O-WinSpoon: A Hammerspoon Windows Management Tool ===
---
--- With this script you will be able to move the window in halves and in corners using your keyboard and mainly using arrows. You can also center the window with full height as well as move to other displays. You would also be able to resize them by thirds, quarters, or halves.
---
--- Official homepage for more info and documentation: [https://github.com/Dillie-O/mir-a-dillieo-winspoon](https://github.com/Dillie-O/mir-a-dillieo-winspoon)
---
--- Download: [https://github.com/Dillie-O/mir-a-dillieo-winspoon/raw/master/MirADillieOWinSpoon.spoon.zip](https://github.com/Dillie-O/mir-a-dillieo-winspoon/raw/master/MirADillieOWinSpoon.spoon.zip)
---

local obj={}
obj.__index = obj

-- Metadata
obj.name = "MirADillieOWinSpoon"
obj.version = "1.0"
obj.author = "Sean Patterson <dillieo@gmail.com>"
obj.homepage = "https://github.com/Dillie-O/mir-a-dillieo-winspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- MirADillieOWinSpoon.sizes
--- Variable
--- The sizes that the window can have.
--- The sizes are expressed as dividend of the entire screen's size.
--- For example `{2, 3, 3/2}` means that it can be 1/2, 1/3 and 2/3 of the total screen's size
obj.sizes = {2, 3, 3/2}

--- MirADillieOWinSpoon.Sizes
--- Variable
--- The sizes that the window can have in full-screen.
--- The sizes are expressed as dividend of the entire screen's size.
--- For example `{1, 4/3, 2}` means that it can be 1/1 (hence full screen), 3/4 and 1/2 of the total screen's size
obj.fullScreenSizes = {1, 4/3, 2}

--- MirADillieOWinSpoon.Sizes
--- Variable
--- The widths that the window can have in center-screen.
--- The sizes are expressed as dividend of the entire screen's width. The height is the full height.
--- For example `{3/2, 3, 2, 4/3}` means that it can be 2/3, 1/3, 1/2, and 3/4 of the total screen's width.
obj.centerScreenSizes = {3/2, 3, 2, 4/3}

--- MirADillieOWinSpoon.GRID
--- Variable
--- The screen's size using `hs.grid.setGrid()`
--- This parameter is used at the spoon's `:init()`
obj.GRID = {w = 24, h = 24}

obj._pressed = {
  up = false,
  down = false,
  left = false,
  right = false
}

function obj:_nextStep(dim, offs, cb)
  if hs.window.focusedWindow() then
    local axis = dim == 'w' and 'x' or 'y'
    local oppDim = dim == 'w' and 'h' or 'w'
    local oppAxis = dim == 'w' and 'y' or 'x'
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = self.sizes[1]
    for i=1,#self.sizes do
      if cell[dim] == self.GRID[dim] / self.sizes[i] and
        (cell[axis] + (offs and cell[dim] or 0)) == (offs and self.GRID[dim] or 0)
        then
          nextSize = self.sizes[(i % #self.sizes) + 1]
        break
      end
    end

    cb(cell, nextSize)
    if cell[oppAxis] ~= 0 and cell[oppAxis] + cell[oppDim] ~= self.GRID[oppDim] then
      cell[oppDim] = self.GRID[oppDim]
      cell[oppAxis] = 0
    end

    hs.grid.set(win, cell, screen)
  end
end

function obj:_nextFullScreenStep()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = self.fullScreenSizes[1]
    for i=1,#self.fullScreenSizes do
      if cell.w == self.GRID.w / self.fullScreenSizes[i] and
         cell.h == self.GRID.h / self.fullScreenSizes[i] and
         cell.x == (self.GRID.w - self.GRID.w / self.fullScreenSizes[i]) / 2 and
         cell.y == (self.GRID.h - self.GRID.h / self.fullScreenSizes[i]) / 2 then
        nextSize = self.fullScreenSizes[(i % #self.fullScreenSizes) + 1]
        break
      end
    end

    cell.w = self.GRID.w / nextSize
    cell.h = self.GRID.h / nextSize
    cell.x = (self.GRID.w - self.GRID.w / nextSize) / 2
    cell.y = (self.GRID.h - self.GRID.h / nextSize) / 2

    hs.grid.set(win, cell, screen)
  end
end

function obj:_fullDimension(dim)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()
    cell = hs.grid.get(win, screen)

    if (dim == 'x') then
      cell = '0,0 ' .. self.GRID.w .. 'x' .. self.GRID.h
    else
      cell[dim] = self.GRID[dim]
      cell[dim == 'w' and 'x' or 'y'] = 0
    end

    hs.grid.set(win, cell, screen)
  end
end

function obj:_nextCenterScreenStep()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = self.centerScreenSizes[1]
    for i=1,#self.centerScreenSizes do
      if cell.w == self.GRID.w / self.centerScreenSizes[i] and
         cell.x == (self.GRID.w - self.GRID.w / self.centerScreenSizes[i]) / 2 then
        nextSize = self.centerScreenSizes[(i % #self.centerScreenSizes) + 1]
        break
      end
    end

    cell.w = self.GRID.w / nextSize
    cell.h = self.GRID.h
    cell.x = (self.GRID.w - self.GRID.w / nextSize) / 2
    cell.y = 0

    hs.grid.set(win, cell, screen)
  end
end

function obj:_nextMonitorLeft()
  if hs.window.focusedWindow() then
    hs.window.frontmostWindow():moveOneScreenWest(true, true)
  end
end

function obj:_nextMonitorRight()
  if hs.window.focusedWindow() then
    hs.window.frontmostWindow():moveOneScreenEast(true, true)
  end
end

function obj:_nextMonitorUp()
  if hs.window.focusedWindow() then
    hs.window.frontmostWindow():moveOneScreenNorth(true, true)
  end
end

function obj:_nextMonitorDown()
  if hs.window.focusedWindow() then
    hs.window.frontmostWindow():moveOneScreenSouth(true, true)
  end
end

--- MirADillieOWinSpoon:bindHotkeys()
--- Method
--- Binds hotkeys for Mir-A-Dillie-O WinSpoon
--- Parameters:
---  * mapping - A table containing hotkey details for the following items:
---   * up: for the up action (usually {activator, "up"})
---   * right: for the right action (usually {activator, "right"})
---   * down: for the down action (usually {activator, "down"})
---   * left: for the left action (usually {activator, "left"})
---   * fullscreen: for the full-screen action (e.g. {activator, "f"})
---   * centerscreen: for the center-screen action (e.g. {activator, "c"})
---   * monitorleft: for monitor left action (e.g. {activatorPlus, "left"})
---   * monitorright: for monitor right action (e.g. {activatorPlus, "right"})
---   * monitorup for monitor up action (e.g. {activatorPlus, "up"})
---   * monitordown: for monitor down action (e.g. {activatorPlus, "down"})
---
--- A configuration example can be:
--- ```
--- local activator = {"alt", "cmd"}
--- local activatorPlus = {"ctrl", "alt", "cmd"}
--- spoon.MirADillieOWinSpoon:bindHotkeys({
---   up = {activator, "up"},
---   right = {activator, "right"},
---   down = {activator, "down"},
---   left = {activator, "left"},
---   fullscreen = {activator, "f"}
---   centerscreen = {activator, "c"}
---   monitorleft = {activatorPlus, "left"}
---   monitorright = {activatorPlus, "right"}
---   monitorup = {activatorPlus, "up"}
---   monitordown = {activatorPlus, "down"}
--- })
--- ```
function obj:bindHotkeys(mapping)
  hs.inspect(mapping)
  print("Bind Hotkeys for Mir-a-Dillie-O WinSpoon")

  hs.hotkey.bind(mapping.down[1], mapping.down[2], function ()
    self._pressed.down = true
    if self._pressed.up then
      self:_fullDimension('h')
    else
      self:_nextStep('h', true, function (cell, nextSize)
        cell.y = self.GRID.h - self.GRID.h / nextSize
        cell.h = self.GRID.h / nextSize
      end)
    end
  end, function ()
    self._pressed.down = false
  end)

  hs.hotkey.bind(mapping.right[1], mapping.right[2], function ()
    self._pressed.right = true
    if self._pressed.left then
      self:_fullDimension('w')
    else
      self:_nextStep('w', true, function (cell, nextSize)
        cell.x = self.GRID.w - self.GRID.w / nextSize
        cell.w = self.GRID.w / nextSize
      end)
    end
  end, function ()
    self._pressed.right = false
  end)

  hs.hotkey.bind(mapping.left[1], mapping.left[2], function ()
    self._pressed.left = true
    if self._pressed.right then
      self:_fullDimension('w')
    else
      self:_nextStep('w', false, function (cell, nextSize)
        cell.x = 0
        cell.w = self.GRID.w / nextSize
      end)
    end
  end, function ()
    self._pressed.left = false
  end)

  hs.hotkey.bind(mapping.up[1], mapping.up[2], function ()
    self._pressed.up = true
    if self._pressed.down then
        self:_fullDimension('h')
    else
      self:_nextStep('h', false, function (cell, nextSize)
        cell.y = 0
        cell.h = self.GRID.h / nextSize
      end)
    end
  end, function ()
    self._pressed.up = false
  end)

  hs.hotkey.bind(mapping.fullscreen[1], mapping.fullscreen[2], function ()
    self:_nextFullScreenStep()
  end)

  hs.hotkey.bind(mapping.centerscreen[1], mapping.centerscreen[2], function ()
    self:_nextCenterScreenStep()
  end)

  hs.hotkey.bind(mapping.monitorleft[1], mapping.monitorleft[2], function ()
    self:_nextMonitorLeft()
  end)

  hs.hotkey.bind(mapping.monitorright[1], mapping.monitorright[2], function ()
    self:_nextMonitorRight()
  end)

  hs.hotkey.bind(mapping.monitorup[1], mapping.monitorup[2], function ()
    self:_nextMonitorUp()
  end)

  hs.hotkey.bind(mapping.monitordown[1], mapping.monitordown[2], function ()
    self:_nextMonitorDown()
  end)

end

function obj:init()
  print("Initializing Mir-a-Dillie-O WinSpoon")
  hs.grid.setGrid(obj.GRID.w .. 'x' .. obj.GRID.h)
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

return obj

local Craft = require 'craft'
local Level = require 'level'

local Controller = {
}

function Controller:reset()
   Level:reset()
   Craft:reset()
end

function Controller:draw()
   Craft:draw()
   Level:draw()
end

function Controller:update(dt)
   Craft:update(dt)
   local event = Level:interactWith(Craft)
   if event == Level.Event.PLAYER_DEATH then
      Craft:reset()
   end
end

return Controller

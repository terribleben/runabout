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
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.rectangle('line', 12, 12, 128, 12)
   love.graphics.rectangle('fill', 12, 12, 128 * Craft.fuel, 12)
   love.graphics.print("fuel", 12, 32)
end

function Controller:update(dt)
   Craft:update(dt)
   Level:update(dt)
   local event = Level:interactWith(Craft)
   if event == Level.Event.PLAYER_DEATH then
      Craft:reset()
   end
end

return Controller

local Camera = require 'camera'
local Craft = require 'craft'
local Level = require 'level'

local Controller = {
}

function Controller:reset()
   Level:reset()
   Craft:reset()
   Craft.position = {
      x = Level.initialPlayerPosition.x,
      y = Level.initialPlayerPosition.y,
   }
end

function Controller:draw()
   Level:drawBackground()
   Level:draw()
   love.graphics.setColor(227 / 255, 87 / 255, 91 / 255, 1)
   love.graphics.rectangle('line', 12, 12, 128, 12)
   love.graphics.rectangle('fill', 12, 12, 128 * Craft.fuel, 12)
end

function Controller:update(dt)
   Craft:update(dt)
   Level:update(dt)
   if Craft.position.x > Level.size.width then
      Craft.position.x = Level.size.width
   end
   if Craft.position.x < 0 then
      Craft.position.x = 0
   end
   Camera:update(Level, Craft.position, dt)
   local event = Level:interactWith(Craft)
   if event == Level.Event.PLAYER_DEATH then
      self:reset()
   end
end

return Controller

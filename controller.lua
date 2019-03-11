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
   if Level:collidesWith(Craft.position.x, Craft.position.y) then
      Craft:reset()
   end
end

return Controller

local Craft = require 'craft'
local Geom = require 'geom'

local Goal = {
   position = { x = 0, y = 0 },
   size = {
      width = 96 * 2,
      height = 196,
   },

   Event = {
      NONE = 0,
      REACHED = 1,
   },
}

function Goal:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Goal:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.setColor(1, 1, 1, 1)
   -- body
   love.graphics.rectangle(
      'fill',
      self.size.width * -0.5, self.size.height * -1,
      (self.size.width * 0.5) - Craft.radius * 0.5, self.size.height
   )
   love.graphics.rectangle(
      'fill',
      Craft.radius * 0.5, self.size.height * -1,
      (self.size.width * 0.5) - Craft.radius * 0.5, self.size.height
   )
   love.graphics.rectangle(
      'fill',
      self.size.width * -0.5, self.size.height * -1,
      self.size.width, (self.size.height * 0.5) - Craft.radius * 0.5
   )
   love.graphics.rectangle(
      'fill',
      self.size.width * -0.5, -(self.size.height * 0.5) + Craft.radius * 0.5,
      self.size.width, (self.size.height * 0.5) - Craft.radius * 0.5
   )
   -- fins
   love.graphics.polygon(
      'fill',
      self.size.width * -0.7, self.size.height * -0.5,
      self.size.width * -0.5, self.size.height * -0.65,
      self.size.width * -0.5, self.size.height * -0.35
   )
   love.graphics.polygon(
      'fill',
      self.size.width * 0.7, self.size.height * -0.5,
      self.size.width * 0.5, self.size.height * -0.65,
      self.size.width * 0.5, self.size.height * -0.35
   )
   love.graphics.pop()
end

function Goal:interactWith(craft)
   local distance = Geom.distance2(self.position, craft.position)
   if distance < self.size.width * 0.5 then
      return self.Event.REACHED
   end
   return self.Event.NONE
end

return Goal

local Geom = require 'geom'

local Door = {
   position = { x = 0, y = 0 },
   radius = 24,
   isOpen = false,

   Event = {
      NONE = 0,
      ENTER = 1,
   },
}

function Door:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Door:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   if self.isOpen then
      love.graphics.setColor(1, 0, 1, 1)
   else
      love.graphics.setColor(0.5, 0.5, 0.5, 1)
   end
   love.graphics.circle(
      'line',
      0, 0, self.radius
   )
   love.graphics.pop()
end

function Door:interactWith(craft)
   if self.isOpen and self:_intersects(craft.position.x, craft.position.y) then
      return self.Event.ENTER
   end
   return self.Event.NONE
end

function Door:_intersects(x, y)
   local distance = Geom.distance(
      self.position.x, self.position.y,
      x, y
   )
   return distance <= self.radius
end

return Door

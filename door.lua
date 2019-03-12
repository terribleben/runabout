local Geom = require 'geom'

local Door = {
   position = { x = 0, y = 0 },
   radius = 24,
   isOpen = false,
   destination = 1,
   color = nil,

   Event = {
      NONE = 0,
      ENTER = 1,
   },
   Colors = {
      NONE = 0,
      BLUE = 1,
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
   love.graphics.setColor(216 / 255, 149 / 255, 110 / 255, 1)
   local time = love.timer.getTime()
   love.graphics.rotate(time * 6)
   love.graphics.circle('line', 0, 0, self.radius, 3)
   if self.isOpen then
      if self.color == self.Colors.BLUE then
         love.graphics.setColor(122 / 255, 243 / 255, 236 / 255, 1)
      else
         love.graphics.setColor(1, 1, 1, 1)
      end
      love.graphics.rotate(time * 0.5)
      love.graphics.circle('line', 0, 0, self.radius * 0.8, 3)
   else
   end
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

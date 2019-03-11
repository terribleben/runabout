local Pond = {
   position = { x = 0, y = 0 },
   size = { width = 0, height = 0 },

   Event = {
      NONE = 0,
      REFUEL = 1,
      PLAYER_DEATH = 2,
   },
}

function Pond:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Pond:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.setColor(0.5, 0.5, 0.5, 1)
   love.graphics.rectangle('fill', 0, 0, self.size.width, self.size.height)
   love.graphics.pop()
end

function Pond:interactWith(craft)
   if self:_contains(craft.position.x, craft.position.y) then
      return self.Event.PLAYER_DEATH
   end
   return self.Event.NONE
end

function Pond:_contains(x, y)
   return x >= self.position.x and y >= self.position.y
      and x <= self.position.x + self.size.width
      and y <= self.position.y + self.size.height
end

return Pond

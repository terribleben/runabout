local Pond = {
   position = { x = 0, y = 0 },
   size = { width = 0, height = 0 },
   isRefueling = false,
   refuelTargetPosition = nil,
   refuelTargetAngle = 0,
   refuelMagnitude = 0,

   Event = {
      NONE = 0,
      REFUEL = 1,
      PLAYER_DEATH = 2,
   },
}

local _PROXIMITY_BUFFER = 64

function Pond:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Pond:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.setColor(227 / 255, 87 / 255, 91 / 255, 1)
   love.graphics.rectangle('fill', 0, 0, self.size.width, self.size.height)
   if self.refuelMagnitude > 0 then
      love.graphics.push()
      love.graphics.translate(self.refuelTargetPosition.x, self.refuelTargetPosition.y)
      love.graphics.rotate(self.refuelTargetAngle)
      local radius = 12 * self.refuelMagnitude
      love.graphics.rectangle('fill', 0, radius * -0.5, _PROXIMITY_BUFFER + 12, radius)
      love.graphics.pop()
   end
   love.graphics.pop()
end

function Pond:update(dt)
   if self.isRefueling then
      self.refuelMagnitude = self.refuelMagnitude + 0.3
      if self.refuelMagnitude > 1 then self.refuelMagnitude = 1 end
   else
      self.refuelMagnitude = self.refuelMagnitude - 0.5
      if self.refuelMagnitude < 0 then self.refuelMagnitude = 0 end
   end
end

function Pond:interactWith(craft)
   self.isRefueling = false
   local targetAngle = craft.angle + math.pi * 0.5
   if self:_contains(craft.position.x, craft.position.y) then
      return self.Event.PLAYER_DEATH
   elseif self:_isProximate(craft.position.x, craft.position.y, targetAngle) then
      self.isRefueling = true
      self.refuelTargetPosition = {
         x = craft.position.x - self.position.x,
         y = craft.position.y - self.position.y,
      }
      self.refuelTargetAngle = targetAngle
      craft:refuel(self.refuelMagnitude)
      return self.Event.REFUEL
   end
   return self.Event.NONE
end

function Pond:_isProximate(x, y, angle)
   return self:_contains(
      x + _PROXIMITY_BUFFER * math.cos(angle),
      y + _PROXIMITY_BUFFER * math.sin(angle)
   )
end

function Pond:_contains(x, y)
   return x >= self.position.x and y >= self.position.y
      and x <= self.position.x + self.size.width
      and y <= self.position.y + self.size.height
end

return Pond

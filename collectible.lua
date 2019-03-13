local Geom = require 'geom'

local Collectible = {
   position = { x = 0, y = 0 },
   radius = 12,
   isCollecting = false,
   targetPosition = nil,
   _accelerationMag = 0,

   Event = {
      NONE = 0,
      PROXIMATE = 1,
      COLLECT = 2,
   },
}

-- TODO: unify proximity buffer or different per object?
local _PROXIMITY_BUFFER = 96

function Collectible:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Collectible:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.setColor(1, 0, 1, 1)
   love.graphics.rectangle(
      'fill',
      self.radius * -0.5,
      self.radius * -0.5,
      self.radius, self.radius
   )
   love.graphics.pop()
end

function Collectible:update(dt)
   if self.isCollecting then
      local distanceToTarget = Geom.distance2(self.position, self.targetPosition)
      self._accelerationMag = math.min(50, self._accelerationMag + 50 * dt)
      local velocity = {
         x = (self.targetPosition.x - self.position.x) * self._accelerationMag,
         y = (self.targetPosition.y - self.position.y) * self._accelerationMag,
      }
      if Geom.magnitude(velocity) * dt >= distanceToTarget then
         self.position.x = self.targetPosition.x
         self.position.y = self.targetPosition.y
      else
         self.position.x = self.position.x + velocity.x * dt
         self.position.y = self.position.y + velocity.y * dt
      end
   end
end

function Collectible:interactWith(craft)
   local targetAngle = craft.angle + math.pi * 0.5
   local isProximate = false
   if self:_intersects(craft.position.x, craft.position.y) then
      return self.Event.COLLECT
   elseif self:_isProximate(craft.position.x, craft.position.y, targetAngle) then
      self.isCollecting = true
      isProximate = true
   end
   if self.isCollecting then
      self.targetPosition = {
         x = craft.position.x,
         y = craft.position.y,
      }
   end
   if isProximate then
      return self.Event.PROXIMATE
   else
      return self.Event.NONE
   end
end

function Collectible:_intersects(x, y)
   local distance = Geom.distance(
      self.position.x, self.position.y,
      x, y
   )
   return distance <= self.radius * 2 -- lolb
end

function Collectible:_isProximate(x, y, angle)
   local isBoundedToSegment, point = Geom.nearestPointOnLineBoundedToSegment(
      { x = x, y = y },
      { x = x + _PROXIMITY_BUFFER * math.cos(angle), y = y + _PROXIMITY_BUFFER * math.sin(angle) },
      { x = self.position.x, y = self.position.y }
   )
   if isBoundedToSegment then
      local distance = Geom.distance(self.position.x, self.position.y, point.x, point.y)
      return distance < self.radius
   end
   return false
end

return Collectible

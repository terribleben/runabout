local Geom = require 'geom'
local SharedState = require 'sharedstate'

local Collectible = {
   position = nil,
   velocity = nil,
   radius = 12,
   isCollecting = false,
   targetPosition = nil,
   _accelerationMag = 0,
   shape = 0,
   _initialPosition = nil,

   Event = {
      NONE = 0,
      PROXIMATE = 1,
      COLLECT = 2,
   },

   Shapes = {
      BORING = 0,
      SPECIAL = 1,
      UPGRADE = 2,
   },
}

-- TODO: unify proximity buffer or different per object?
local _PROXIMITY_BUFFER = 86

function Collectible:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Collectible:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   if self.shape == self.Shapes.BORING then
      love.graphics.setColor(1, 0, 1, 1)
      love.graphics.rectangle(
         'fill',
         self.radius * -0.5,
         self.radius * -0.5,
         self.radius, self.radius
      )
   elseif self.shape == self.Shapes.SPECIAL then
      if SharedState.isBoostEnabled then
         love.graphics.setColor(0, 1, 1, 1)
      else
         love.graphics.setColor(0.6, 0.6, 0.6, 1)
      end
      love.graphics.circle(
         'fill',
         0, 0, self.radius * 0.75
      )
   elseif self.shape == self.Shapes.UPGRADE then
      if math.floor(love.timer.getTime() * 6) % 2 == 1 then
         love.graphics.setColor(0, 1, 1, 1)
      else
         love.graphics.setColor(1, 1, 1, 1)
      end
      love.graphics.circle(
         'fill',
         0, 0, self.radius * 0.9
      )
   end
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
   else
      if self._initialPosition == nil then
         self._initialPosition = { y = self.position.y - 4 }
         self.velocity = { y = 0 }
      end
      self.velocity.y = self.velocity.y + (self._initialPosition.y - self.position.y) * 0.4
      self.position.y = self.position.y + self.velocity.y * dt
   end
end

function Collectible:interactWith(craft)
   local targetAngle = craft.angle + math.pi * 0.5
   local isProximate = false
   if self.shape == self.Shapes.SPECIAL and not SharedState.isBoostEnabled then
      -- no boost ability, do not pick up
      return self.Event.NONE
   end
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

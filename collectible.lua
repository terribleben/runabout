

local Collectible = {
   position = { x = 0, y = 0 },
   radius = 12,
   isCollecting = false,
   targetPosition = nil,

   Event = {
      NONE = 0,
      PROXIMATE = 1,
      PLAYER_COLLECT = 2,
   },
}

-- TODO: unify proximity buffer or different per object?
local _PROXIMITY_BUFFER = 64

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

function Collectible:interactWith(craft)
   local targetAngle = craft.angle + math.pi * 0.5
   local isProximate = false
   if self:_intersects(craft.position.x, craft.position.y) then
      return self.Event.PLAYER_COLLECT
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
   -- TODO
   return false
end

function Collectible:_isProximate(x, y, angle)
   -- distance from self.position
   -- to a line from x, y, x + angle, y + angle
   -- TODO
   return false
end

return Collectible

local SharedState = require 'sharedstate'

local Camera = {
   _position = { x = 0, y = 0 },
   _displacement = { x = 0, y = 0 },
   _velocity = { x = 0, y = 0 },
   _interp = { x = 0 }
}

local _VERTICAL_BUFFER = 150

function Camera:update(level, focus_Position, dt)
   self._position.x = focus_Position.x - SharedState.viewport.width * 0.5
   if self._position.x < 0 then self._position.x = 0 end
   if self._position.x > level.size.width - SharedState.viewport.width then
      self._position.x = level.size.width - SharedState.viewport.width
   end

   self._interp.x = self._position.x / (level.size.width - SharedState.viewport.width)
   
   self._position.y = focus_Position.y - SharedState.viewport.height * 0.5
   if self._position.y > 0 then self._position.y = 0 end
   if self._position.y < -(level.size.height - SharedState.viewport.height) then
      self._position.y = -(level.size.height - SharedState.viewport.height)
   end

   self._velocity.x = self._velocity.x + (self._displacement.x * -0.91)
   self._velocity.y = self._velocity.y + (self._displacement.y * -0.91)
   self._displacement.x = 0.88 * (self._displacement.x + self._velocity.x)
   self._displacement.y = 0.88 * (self._displacement.y + self._velocity.y)
end

function Camera:getPosition()
   return {
      x = self._position.x + self._displacement.x,
      y = self._position.y, -- + self._displacement.y,
   }
end

-- return [0, 1]
-- where 0 means the camera is panned totally left in the level
-- and 1 means the camera is panned totally right in the level
function Camera:getXInterp()
   return self._interp.x
end

function Camera:shake()
   local radius = 8
   local angle = 0 --math.random() * math.pi * 2
   self._displacement.x = radius * math.cos(angle)
   self._displacement.y = radius * math.cos(angle)
end

return Camera

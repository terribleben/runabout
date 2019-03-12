local SharedState = require 'sharedstate'

local Camera = {
   position = { x = 0, y = 0 }
}

local _VERTICAL_BUFFER = 150

function Camera:update(level, focusPosition, dt)
   self.position.x = focusPosition.x - SharedState.viewport.width * 0.5
   if self.position.x < 0 then self.position.x = 0 end
   if self.position.x > level.size.width - SharedState.viewport.width then
      self.position.x = level.size.width - SharedState.viewport.width
   end
   self.position.y = focusPosition.y - SharedState.viewport.height * 0.5
   if self.position.y > 0 then self.position.y = 0 end
   if self.position.y < -(level.size.height - SharedState.viewport.height) then
      self.position.y = -(level.size.height - SharedState.viewport.height)
   end
end

return Camera

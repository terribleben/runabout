local SharedState = require 'sharedstate'

local Camera = {
   position = { x = 0, y = 0 }
}

function Camera:update(level, focusPosition, dt)
   self.position.x = focusPosition.x - SharedState.viewport.width * 0.5
   if self.position.x < 0 then self.position.x = 0 end
   if self.position.x > level.size.width - SharedState.viewport.width then
      self.position.x = level.size.width - SharedState.viewport.width
   end
end

return Camera

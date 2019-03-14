local Colors = require 'colors'
local SharedState = require 'sharedstate'
local Thruster = require 'thruster'

local Craft = {
   position = { x = 0, y = 0 },
   velocity = { x = 0, y = 0 },
   radius = 24,
   angle = 0,
   fuel = 1,
   state = 0,
   thruster = nil,

   states = {
      READY = 0,
      PLAYING = 1,
   },
}

local maxVelocity = { x = 175, y = 250 }
local _READY = 'ready'

function Craft:reset()
   self.state = self.states.READY
   self.fuel = 1
   self.thruster = Thruster:new()
end

function Craft:draw(palette)
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.rotate(self.angle)
   self.thruster:draw()
   if self.state == self.states.PLAYING then
      love.graphics.setColor(1, 1, 1, 1)
   elseif self.state == self.states.READY then
      if math.floor(love.timer.getTime() * 6) % 2 == 1 then
         love.graphics.setColor(1, 1, 1, 1)
      else
         Colors.useColor(palette, Colors.Value.DOOR)
      end
      local mediumFont = SharedState.font.medium
      love.graphics.setFont(mediumFont)
      local titleWidth = mediumFont:getWidth(_READY)
      love.graphics.print(
         _READY,
         titleWidth * -0.5,
         32 + (-mediumFont:getHeight() * 0.5)
      )
   end
   love.graphics.rectangle(
      'fill',
         -self.radius * 0.5, -self.radius * 0.5,
      self.radius, self.radius
   )
   love.graphics.pop()
end

function Craft:update(dt)
   local acceleration = { x = 0, y = 0 }
   acceleration.y = 15
   self.angle = 0
   if love.keyboard.isDown('up') and (self.fuel > 0 or SharedState.boost > 0) then
      if SharedState.boost > 0 then
         acceleration.y = acceleration.y - 30
         SharedState.boost = SharedState.boost - 0.2 * dt
         if SharedState.boost < 0 then SharedState.boost = 0 end
      else
         acceleration.y = acceleration.y - 25
         self.fuel = self.fuel - 0.15 * dt
         if self.fuel < 0 then self.fuel = 0 end
      end
      if self.state ~= self.states.PLAYING then
         self.state = self.states.PLAYING
         self.velocity.y = -5
      end
   end
   if love.keyboard.isDown('right') then
      acceleration.x = 15
   elseif love.keyboard.isDown('left') then
      acceleration.x = -15
   else
      self.velocity.x = self.velocity.x * 0.8
   end
   if self.state == self.states.PLAYING then
      if SharedState.environment.windy then
         acceleration.x = acceleration.x - 6.5
      end
      self.velocity.x = self.velocity.x + acceleration.x
      self.velocity.y = self.velocity.y + acceleration.y
      if self.velocity.y > maxVelocity.y then self.velocity.y = maxVelocity.y end
      if self.velocity.y < -maxVelocity.y then self.velocity.y = -maxVelocity.y end
      if self.velocity.x > maxVelocity.x then self.velocity.x = maxVelocity.x end
      if self.velocity.x < -maxVelocity.x then self.velocity.x = -maxVelocity.x end
      self.position.x = self.position.x + self.velocity.x * dt
      self.position.y = self.position.y + self.velocity.y * dt
      self.angle = self.velocity.x * 0.002
      self.thruster:update(dt, love.keyboard.isDown('up'))
   end
end

function Craft:refuel(magnitude)
   self.fuel = self.fuel + magnitude * 0.008
   if self.fuel > 1 then self.fuel = 1 end
end

return Craft

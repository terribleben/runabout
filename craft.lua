local Craft = {
   position = { x = 400, y = 400 },
   velocity = { x = 0, y = 0 },
   radius = 20,
   angle = 0,
}

local maxVelocity = { x = 175, y = 250 }

function Craft:draw()
   love.graphics.push()
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.rotate(self.angle)
   love.graphics.rectangle(
      'line',
         -self.radius * 0.5, -self.radius * 0.5,
      self.radius, self.radius
   )
   love.graphics.pop()
end

function Craft:update(dt)
   local acceleration = { x = 0, y = 0 }
   acceleration.y = 15
   self.angle = 0
   if love.keyboard.isDown('down') then
      acceleration.y = acceleration.y - 25
   end
   if love.keyboard.isDown('left') then
      acceleration.x = 15
   elseif love.keyboard.isDown('right') then
      acceleration.x = -15
   else
      self.velocity.x = self.velocity.x * 0.8
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
end

return Craft

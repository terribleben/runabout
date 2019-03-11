local Craft = {
   position = { x = 0, y = 0 },
   velocity = { x = 0, y = 0 },
   radius = 20,
   angle = 0,
   fuel = 1,
   isActive = false
}

local maxVelocity = { x = 175, y = 250 }

function Craft:reset()
   self.isActive = false
   self.position.x = 400
   self.position.y = 200
   self.fuel = 1
end

function Craft:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.rotate(self.angle)
   if self.isActive then
      love.graphics.setColor(1, 1, 1, 1)
   else
      if math.floor(love.timer.getTime() * 4) % 2 == 1 then
         love.graphics.setColor(1, 1, 1, 1)
      else
         love.graphics.setColor(0.5, 0.5, 0.5, 1)
      end
      love.graphics.print("ready", -16, 16)
   end
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
   if love.keyboard.isDown('down') and self.fuel > 0 then
      acceleration.y = acceleration.y - 25
      if not self.isActive then
         self.isActive = true
         self.velocity.y = -5
      end
      self.fuel = self.fuel - 0.1 * dt
      if self.fuel < 0 then self.fuel = 0 end
   end
   if love.keyboard.isDown('left') then
      acceleration.x = 15
   elseif love.keyboard.isDown('right') then
      acceleration.x = -15
   else
      self.velocity.x = self.velocity.x * 0.8
   end
   if self.isActive then
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
end

function Craft:refuel(magnitude)
   self.fuel = self.fuel + magnitude * 0.008
   if self.fuel > 1 then self.fuel = 1 end
end

return Craft

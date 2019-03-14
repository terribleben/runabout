local Particle = {
   x = 0,
   y = 0,
   radius = 0,
   ttl = 0,
   lifespan = 0
}

function Particle:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   p.ttl = p.lifespan
   return p
end

function Particle:update(dt)
   self.ttl = self.ttl - dt
end

function Particle:draw(dt)
   if self.ttl > 0 then
      love.graphics.setColor(1, 1, 1, (self.ttl / self.lifespan))
      love.graphics.circle('fill', self.x, self.y, self.radius)
   end
end

-- DoorParticle

local DoorParticle = {
   x = 0,
   y = 0,
   r = 0,
   vr = 0,
   ttl = 0,
   lifespan = 0
}

function DoorParticle:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   p.ttl = p.lifespan
   p.vr = 75 + p.index * 50
   return p
end

function DoorParticle:update(dt)
   self.ttl = self.ttl - dt
   self.r = self.r + self.vr * dt
   self.vr = self.vr - (75 * dt)
   if self.vr < 0 then self.vr = 0 end
end

function DoorParticle:draw(dt)
   if self.ttl > 0 then
      love.graphics.setColor(1, 1, 1, (self.ttl / self.lifespan))
      love.graphics.circle('line', self.x, self.y, self.r)
   end
end

-- WindParticle

local WindParticle = {
   x = 0,
   y = 0,
   yInit = 0,
   vx = 0,
   vy = 0,
   radius = 0,
   ttl = 0,
   lifespan = 0
}

function WindParticle:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   p.ttl = p.lifespan
   p.yInit = p.y - p.vy
   return p
end

function WindParticle:update(dt)
   self.ttl = self.ttl - dt
   self.vy = self.vy + (self.yInit - self.y) * 0.1
   self.x = self.x + self.vx * dt
   self.y = self.y + self.vy * dt
end

function WindParticle:draw(dt)
   if self.ttl > 0 then
      love.graphics.setColor(0, 0, 0, 0.3)
      love.graphics.circle('fill', self.x, self.y, self.radius)
   end
end

return function()
   return Particle, WindParticle, DoorParticle
end

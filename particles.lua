local Particle, WindParticle, DoorParticle, CraftParticle = require 'particle' ()
local SharedState = require 'sharedstate'

local Particles = {
   _particles = {},
   _nextParticleIndex = 1,
   _foregroundParticles = {},
   _nextForegroundParticleIndex = 1,
}

function Particles:add(count, Kind, proto, foreground)
   proto = proto or Kind:new()
   for index = 0, count - 1 do
      local clone = {}
      for k, v in pairs(proto) do clone[k] = v end
      clone.index = index
      if foreground then
         self._foregroundParticles[self._nextForegroundParticleIndex] = Kind:new(clone)
         self._nextForegroundParticleIndex = self._nextForegroundParticleIndex + 1
      else
         self._particles[self._nextParticleIndex] = Kind:new(clone)
         self._nextParticleIndex = self._nextParticleIndex + 1
      end
   end
end

function Particles:draw()
   for index, particle in pairs(self._particles) do
      particle:draw()
   end
end

function Particles:drawForeground()
   for index, particle in pairs(self._foregroundParticles) do
      particle:draw()
   end
end

function Particles:update(dt)
   for index, particle in pairs(self._particles) do
      particle:update(dt)
      if particle.ttl <= 0 then
         self._particles[index] = nil
      end
   end
   for index, particle in pairs(self._foregroundParticles) do
      particle:update(dt)
      if particle.ttl <= 0 then
         self._foregroundParticles[index] = nil
      end
   end
end

function Particles:doorOpened(door)
   self:add(
      3,
      DoorParticle,
      {
         x = door.position.x,
         y = door.position.y,
         lifespan = 2,
      },
      false
   )
end

function Particles:playerDeath(craft)
   self:add(
      10,
      CraftParticle,
      {
         x = craft.position.x,
         y = craft.position.y,
         radius = 3,
         lifespan = 0.5,
      },
      false
   )
end

function Particles:wind()
   local vx, vy = math.random(-600, -800), math.random(-10, 10)
   self:add(
      1,
      WindParticle,
      {
         x = math.random(0, SharedState.viewport.width + 100),
         y = math.random(0, SharedState.viewport.height),
         vx = vx,
         vy = vy,
         radius = math.random(2, 4),
         lifespan = SharedState.viewport.width / -vx,
      },
      true
   )
end

return Particles

local SharedState = require 'sharedstate'

local Thruster = {
   _particles = {},
}

local _PARTICLE_COUNT = 10
local _THRUSTER_DISTANCE = 96

function Thruster:new(p)
   p = p or { _particles = {} }
   setmetatable(p, { __index = self })
   for i = 1, _PARTICLE_COUNT do
      table.insert(
         p._particles,
         {
            x = -18 + math.random() * 36,
            y = math.random(0, _THRUSTER_DISTANCE),
            vx = 0,
            vy = 0,
            mass = math.random(),
         }
      )
   end
   return p
end

function Thruster:draw()
   for index = 1, _PARTICLE_COUNT do
      local p = self._particles[index]
      if SharedState.boost > 0 then
         love.graphics.setColor(0, 1, 1, math.min(1, -p.vy / 400))
      else
         love.graphics.setColor(1, 1, 1, math.min(1, -p.vy / 400))
      end
      love.graphics.circle('fill', p.x, p.y, 1.5 + p.mass)
   end
end

function Thruster:update(dt, isActive)
   for index = 1, _PARTICLE_COUNT do
      local p = self._particles[index]
      if isActive then
         local attractor = { x = 0, y = 0 }
         if math.random() < 0.2 then
            attractor.y = math.random(-8, 8)
         end
         local accCoeff = 0.25 - p.mass * 0.21
         local acceleration = {
            x = (attractor.x - p.x) * accCoeff,
            y = -(_THRUSTER_DISTANCE - (attractor.y - p.y)) * accCoeff,
         }
         p.vx = p.vx + acceleration.x
         p.vy = p.vy + acceleration.y
      else
         p.vx = p.vx * 0.84
         p.vy = p.vy * 0.84
      end
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt
      if p.y <= 0 or math.random() < 0.2 * dt then
         p.y = _THRUSTER_DISTANCE
         p.x = -18 + math.random() * 36
         p.vx = 0
         p.vy = 0
      end
   end
end

return Thruster

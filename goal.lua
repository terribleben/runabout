local Colors = require 'colors'
local Craft = require 'craft'
local Geom = require 'geom'
local SharedState = require 'sharedstate'

local Goal = {
   position = { x = 0, y = 0 },
   size = {
      width = 96 * 2,
      height = 196,
   },
   _isAnimating = false,
   _animation = {
      craftPosition = nil,
      craftAngle = nil,
      timer = 0,
      stage = 0,
      frameTimer = 0,
      bolts = nil,
   },

   Event = {
      NONE = 0,
      REACHED = 1,
      FINISHED = 2,
   },
}

local _FRAME_DUR = 0.1

function Goal:new(p)
   p = p or {}
   setmetatable(p, { __index = self })
   return p
end

function Goal:draw()
   love.graphics.push()
   love.graphics.translate(self.position.x, self.position.y)
   love.graphics.setColor(1, 1, 1, 1)
   -- body
   love.graphics.rectangle(
      'fill',
      self.size.width * -0.5, self.size.height * -1,
      (self.size.width * 0.5) - Craft.radius * 0.5, self.size.height
   )
   love.graphics.rectangle(
      'fill',
      Craft.radius * 0.5, self.size.height * -1,
      (self.size.width * 0.5) - Craft.radius * 0.5, self.size.height
   )
   love.graphics.rectangle(
      'fill',
      self.size.width * -0.5, self.size.height * -1,
      self.size.width, (self.size.height * 0.5) - Craft.radius * 0.5
   )
   love.graphics.rectangle(
      'fill',
      self.size.width * -0.5, -(self.size.height * 0.5) + Craft.radius * 0.5,
      self.size.width, (self.size.height * 0.5) - Craft.radius * 0.5
   )
   -- fins
   love.graphics.polygon(
      'fill',
      self.size.width * -0.7, self.size.height * -0.5,
      self.size.width * -0.5, self.size.height * -0.65,
      self.size.width * -0.5, self.size.height * -0.35
   )
   love.graphics.polygon(
      'fill',
      self.size.width * 0.7, self.size.height * -0.5,
      self.size.width * 0.5, self.size.height * -0.65,
      self.size.width * 0.5, self.size.height * -0.35
   )
   if self._isAnimating then
      love.graphics.setColor(0, 1, 1, 0.3)
      for index, x in pairs(self._animation.bolts) do
         love.graphics.rectangle('fill', x, -self.size.height, 10, self.size.height)
      end
   end
   love.graphics.pop()

   if self._isAnimating then
      self:_drawCutscene()
   end
end

function Goal:update(dt)
   if self._isAnimating then
      self._animation.timer = self._animation.timer - dt
      self._animation.frameTimer = self._animation.frameTimer - dt
      if self._animation.frameTimer <= 0 then
         self._animation.frameTimer = _FRAME_DUR
         self:_doFrame()
      end
      if self._animation.stage == 0 then
         self._animation.craftAngle = self._animation.craftAngle * 0.9
         if self._animation.timer < 0 then
            self._animation.timer = 6
            self._animation.stage = 1
         end
      elseif self._animation.stage == 1 then
         self._animation.craftPosition.x = self._animation.craftPosition.x + (self.position.x - self._animation.craftPosition.x) * 0.6 * dt
         self._animation.craftPosition.y = self._animation.craftPosition.y + ((self.position.y - self.size.height * 0.5) - self._animation.craftPosition.y) * 0.6 * dt
         if self._animation.timer < 0 then
            self._animation.stage = 2
            self._animation.timer = 3
            self._animation.craftPosition.x = self.position.x
            self._animation.craftPosition.y = self.position.y - self.size.height * 0.5
         end
      elseif self._animation.stage == 2 then
         -- wait with player in center
         if self._animation.timer < 0 then
            self._animation.stage = 3
            self._animation.timer = 4
         end
      elseif self._animation.stage == 3 then
         -- showing fade out
         if self._animation.timer < 0 then
            self._animation.stage = 4
         end
      end
   end
end

function Goal:interactWith(craft)
   if self._isAnimating and self._animation.stage >= 4 then
      return self.Event.FINISHED
   end
   local distance = Geom.distance2(self.position, craft.position)
   if distance < self.size.width * 1.2 then
      return self.Event.REACHED
   end
   return self.Event.NONE
end

function Goal:animate(craft)
   if not self._isAnimating then
      self._isAnimating = true
      self._animation = {
         craftPosition = { x = craft.position.x, y = craft.position.y },
         craftAngle = craft.angle,
         timer = 2,
         stage = 0,
         frameTimer = _FRAME_DUR,
      }
      self:_doFrame()
   end
end

function Goal:_drawCutscene()
   love.graphics.push()
   love.graphics.translate(self._animation.craftPosition.x, self._animation.craftPosition.y)
   local radius = 24
   love.graphics.rotate(self._animation.craftAngle)
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.rectangle(
      'fill',
         -radius * 0.5, -radius * 0.5,
      radius, radius
   )
   love.graphics.pop()
end

function Goal:drawForeground()
   if self._isAnimating and self._animation.stage == 3 then
      local alpha = 1.0 - (self._animation.timer / 4)
      love.graphics.setColor(1, 1, 1, alpha)
      love.graphics.rectangle('fill', 0, 0, SharedState.viewport.width, SharedState.viewport.height)
   end
end

function Goal:_doFrame()
   self._animation.bolts = {}
   for i = 1, 3 do
      table.insert(
         self._animation.bolts,
         (self.size.width * -0.5) + math.random() * (self.size.width - 10)
      )
   end
end

return Goal

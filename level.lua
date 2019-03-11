local SharedState = require 'sharedstate'

local Level = {
   segments = {},
   numSegments = 0,
}

local _SEGMENT_HEIGHT = 64

function Level:reset()
   for index = 1, 20 do
      self.segments[index] = math.random(0, 3)
      self.numSegments = self.numSegments + 1
   end
end

function Level:collidesWith(x, y)
   
end

function Level:getGroundBaseline()
   return SharedState.viewport.height - 32
end

function Level:draw()
   love.graphics.setColor(1, 1, 1, 1)
   local prevHeight
   local xx, yy = 0, self:getGroundBaseline()
   for index, height in pairs(self.segments) do
      if prevHeight then
         love.graphics.line(
            xx - _SEGMENT_HEIGHT, yy - prevHeight * _SEGMENT_HEIGHT,
            xx, yy - height * _SEGMENT_HEIGHT
         )
      end
      prevHeight = height
      xx = xx + _SEGMENT_HEIGHT
   end
end

function Level:_getSegmentIndexAtX(xx)
   return math.floor(xx / _SEGMENT_HEIGHT) + 1
end

function Level:_getHeightAtX(xx)
   local baseline = self:getGroundBaseline()
   local collidingSegment = self:_getSegmentIndexAtX(xx)
   local left = { x = (collidingSegment - 1) * _SEGMENT_HEIGHT, y = baseline }
   local right = { x = collidingSegment * _SEGMENT_HEIGHT, y = baseline }
   if collidingSegment > 0 then
      left.y = baseline - self.segments[collidingSegment] * _SEGMENT_HEIGHT
   end
   if collidingSegment < self.numSegments then
      right.y = baseline - self.segments[collidingSegment + 1] * _SEGMENT_HEIGHT
   end
   local interp = (xx - left.x) / _SEGMENT_HEIGHT
   return left.y + (right.y - left.y) * interp
end

function Level:_drawCollisionTest(collidingX)
   local collidingSegment = self:_getSegmentIndexAtX(collidingX)
   if (collidingSegment > 0 and collidingSegment < self.numSegments) then
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.line(
         (collidingSegment - 1) * _SEGMENT_HEIGHT, yy - self.segments[collidingSegment] * _SEGMENT_HEIGHT,
         (collidingSegment) * _SEGMENT_HEIGHT, yy - self.segments[collidingSegment + 1] * _SEGMENT_HEIGHT
      )
   end
   local collideY = self:_getHeightAtX(collidingX)
   love.graphics.circle('line', collidingX, collideY, 10)
end

return Level

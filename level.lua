local Collectible = require 'collectible'
local Door = require 'door'
local Pond = require 'pond'
local SharedState = require 'sharedstate'

local Level = {
   segments = {},
   numSegments = 0,
   ponds = {},
   numPonds = 0,
   collectibles = {},
   numCollectibles = 0,
   numCollectiblesHeld = 0,
   door = nil,

   Event = {
      NONE = 0,
      PLAYER_COLLECT = 1,
      PLAYER_DEATH = 2,
   },
}

local _SEGMENT_HEIGHT = 64

function Level:reset()
   --[[for index = 1, 20 do
      self.segments[index] = math.random(0, 3)
      self.numSegments = self.numSegments + 1
      end--]]
   self.numCollectiblesHeld = 0
   
   self.numSegments = 15
   self.segments = { 0, 0, 1, 1, 0, 0, 0, 1, 2, 1, 2, 3, 3, 3, 3, 3 }

   self.numPonds = 1
   self.ponds = {}
   self.ponds[self.numPonds] = Pond:new({
         position = {
            x = 8 * _SEGMENT_HEIGHT,
            y = self:getGroundBaseline() - _SEGMENT_HEIGHT * 2 + 12,
         },
         size = {
            width = _SEGMENT_HEIGHT * 2,
            height = _SEGMENT_HEIGHT,
         },
   })

   self.numCollectibles = 1
   self.collectibles = {}
   local collectibleX = 11.5 * _SEGMENT_HEIGHT
   self.collectibles[self.numCollectibles] = Collectible:new({
         position = {
            x = collectibleX,
            y = self:_getHeightAtX(collectibleX) - 6,
         },
   })

   self.door = Door:new({
         position = {
            x = 175,
            y = 150,
         },
   })
end

function Level:update(dt)
   for index, pond in pairs(self.ponds) do
      pond:update(dt)
   end
   for index, collectible in pairs(self.collectibles) do
      collectible:update(dt)
   end
end

function Level:interactWith(craft)
   -- terrain
   if self:collidesWith(craft.position.x, craft.position.y) then
      return self.Event.PLAYER_DEATH
   end

   -- ponds
   for index, pond in pairs(self.ponds) do
      local result = pond:interactWith(craft)
      if result == Pond.Event.PLAYER_DEATH then
         return self.Event.PLAYER_DEATH
      end
   end

   -- collectibles
   for index, collectible in pairs(self.collectibles) do
      local result = collectible:interactWith(craft)
      if result == Collectible.Event.PLAYER_COLLECT then
         self.collectibles[index] = nil
         self.numCollectiblesHeld = self.numCollectiblesHeld + 1
         if self.numCollectiblesHeld == self.numCollectibles then
            self.door.isOpen = true
         end
      end
   end

   -- door
   local result = self.door:interactWith(craft)
   if result == Door.Event.ENTER then
      -- todo: transition level
      return self.Event.PLAYER_DEATH
   end

   return self.Event.NONE
end

function Level:collidesWith(x, y)
   local groundY = self:_getHeightAtX(x)
   return y >= groundY
end

function Level:getGroundBaseline()
   return SharedState.viewport.height - 32
end

function Level:draw()
   for index, pond in pairs(self.ponds) do
      pond:draw()
   end
   for index, collectible in pairs(self.collectibles) do
      collectible:draw()
   end

   self.door:draw()
      
   self:_drawSegments()
end

function Level:_drawSegments()
   love.graphics.setColor(1, 1, 1, 1)
   local prevHeight
   local xx, yy = 0, self:getGroundBaseline()
   for index, height in pairs(self.segments) do
      if prevHeight then
         love.graphics.polygon(
            'fill',
            xx - _SEGMENT_HEIGHT, yy - prevHeight * _SEGMENT_HEIGHT,
            xx, yy - height * _SEGMENT_HEIGHT,
            xx, SharedState.viewport.height,
            xx - _SEGMENT_HEIGHT, SharedState.viewport.height
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

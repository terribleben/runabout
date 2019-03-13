local Camera = require 'camera'
local Craft = require 'craft'
local Collectible = require 'collectible'
local Door = require 'door'
local Pond = require 'pond'
local SharedState = require 'sharedstate'

local Level = {
   segments = {},
   ponds = {},
   collectibles = {},
   doors = {},
   size = { width = 0, height = 0 },
   
   numCollectiblesHeld = 0,
   initialPlayerPosition = {},

   Event = {
      NONE = 0,
      COLLECT = 1,
      PLAYER_DEATH = 2,
      ENTER_DOOR = 3,
   },
}

local _GRID_SIZE = 64

function Level:reset()
   --[[for index = 1, 20 do
      self.segments[index] = math.random(0, 3)
      end--]]
   self.numCollectiblesHeld = 0
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
      if result == Collectible.Event.COLLECT then
         self.collectibles[index] = nil
         self.numCollectiblesHeld = self.numCollectiblesHeld + 1
         self:_onPlayerCollect()
         return self.Event.COLLECT
      end
   end

   -- door
   for index, door in pairs(self.doors) do
      local result = door:interactWith(craft)
      if result == Door.Event.ENTER then
         return self.Event.ENTER_DOOR, door
      end
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
   love.graphics.push()
   love.graphics.translate(-Camera.position.x, -Camera.position.y)
   for index, pond in pairs(self.ponds) do
      pond:draw()
   end
   for index, collectible in pairs(self.collectibles) do
      collectible:draw()
   end
   for index, door in pairs(self.doors) do
      door:draw()
   end
   Craft:draw()
   self:_drawSegments()
   love.graphics.pop()
end

function Level:drawBackground()
   self:_drawSky()
end

function Level:_drawSegments()
   love.graphics.setColor(188 / 255, 129 / 255, 73 / 255, 1)
   local prevHeight
   local xx, yy = 0, self:getGroundBaseline()
   for index, height in pairs(self.segments) do
      if prevHeight then
         love.graphics.polygon(
            'fill',
            xx - _GRID_SIZE, yy - prevHeight * _GRID_SIZE,
            xx, yy - height * _GRID_SIZE,
            xx, SharedState.viewport.height,
            xx - _GRID_SIZE, SharedState.viewport.height
         )
      end
      prevHeight = height
      xx = xx + _GRID_SIZE
   end
end

function Level:_getSegmentIndexAtX(xx)
   return math.floor(xx / _GRID_SIZE) + 1
end

function Level:_getHeightAtX(xx)
   local baseline = self:getGroundBaseline()
   local collidingSegment = self:_getSegmentIndexAtX(xx)
   local left = { x = (collidingSegment - 1) * _GRID_SIZE, y = baseline }
   local right = { x = collidingSegment * _GRID_SIZE, y = baseline }
   local nSegments = table.getn(self.segments)
   if collidingSegment > 0 then
      left.y = baseline - self.segments[collidingSegment] * _GRID_SIZE
   end
   if collidingSegment < nSegments then
      right.y = baseline - self.segments[collidingSegment + 1] * _GRID_SIZE
   end
   local interp = (xx - left.x) / _GRID_SIZE
   return left.y + (right.y - left.y) * interp
end

function Level:_drawCollisionTest(collidingX)
   local collidingSegment = self:_getSegmentIndexAtX(collidingX)
   if (collidingSegment > 0 and collidingSegment < nSegments) then
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.line(
         (collidingSegment - 1) * _GRID_SIZE, yy - self.segments[collidingSegment] * _GRID_SIZE,
         (collidingSegment) * _GRID_SIZE, yy - self.segments[collidingSegment + 1] * _GRID_SIZE
      )
   end
   local collideY = self:_getHeightAtX(collidingX)
   love.graphics.circle('line', collidingX, collideY, 10)
end

function Level:_drawSky()
   local color1 = { r = 87, g = 136, b = 98 }
   local color2 = { r = 227, g = 207, b = 126 }
   local numRegions = 12
   local regionSize = SharedState.viewport.height / numRegions
   for i = 0, numRegions - 1 do
      local interp = i / (numRegions - 1)
      local remain = 1.0 - interp
      local color = {
         r = ((color2.r * interp) + (color1.r * remain)) / 255.0,
         g = ((color2.g * interp) + (color1.g * remain)) / 255.0,
         b = ((color2.b * interp) + (color1.b * remain)) / 255.0,
      }
      love.graphics.setColor(color.r, color.g, color.b, 1)
      love.graphics.rectangle(
         'fill',
         0, i * regionSize,
         SharedState.viewport.width, regionSize
      )
   end
end

function Level:_onPlayerCollect()
   if self.levelId == 1 then
      if self.numCollectiblesHeld == 1 then
         self.doors[2].isOpen = true
      end
   elseif self.levelId == 2 then
      if self.numCollectiblesHeld == 5 then
         self.doors[2].isOpen = true
      end
   elseif self.levelId == 3 then
      if self.numCollectiblesHeld == 3 then
         self.doors[2].isOpen = true
      end
   elseif self.levelId == 5 then
      if self.numCollectiblesHeld == 6 then
         self.doors[2].isOpen = true
      end
   elseif self.levelId == 6 then
      if self.numCollectiblesHeld == 2 then
         self.doors[2].isOpen = true
      end
   end
end

function Level:loadLevelData(data)
   self.levelId = data.id

   if data.windy then
      SharedState:setEnvironment({ windy = true })
   else
      SharedState:setEnvironment({ windy = false })
   end
   
   self.segments = {}
   local maxSegment = 0
   for index, segment in pairs(data.segments) do
      table.insert(self.segments, segment)
      if segment > maxSegment then maxSegment = segment end
   end
   local maxHeight = (SharedState.viewport.height - self:getGroundBaseline()) + (_GRID_SIZE * maxSegment) + 200
   
   self.size = {
      width = (table.getn(self.segments) - 1) * _GRID_SIZE,
      height = math.max(SharedState.viewport.height, maxHeight),
   }

   self.ponds = {}
   for index, pond in pairs(data.ponds) do
      local x = pond.index * _GRID_SIZE
      local position = {
         x = x,
         y = self:_getHeightAtX(x) + 12,
      }
      table.insert(
         self.ponds,
         Pond:new({
               position = position,
               size = {
                  width = _GRID_SIZE * pond.width,
                  height = _GRID_SIZE * pond.height,
               }
         })
      )
   end

   self.collectibles = {}
   for index, collectible in pairs(data.collectibles) do
      local x, y
      if collectible.index then
         x = collectible.index * _GRID_SIZE
         y = self:_getHeightAtX(x) - 6
         if collectible.hover then
            y = y - collectible.hover
         end
      end
      table.insert(
         self.collectibles,
         Collectible:new({
               position = {
                  x = x,
                  y = y,
               },
         })
      )
   end

   self.doors = {}
   for index, door in pairs(data.doors) do
      local doorX, isOpen = 0, false
      if door.x > 0 then doorX = door.x else doorX = self.size.width + door.x end
      if door.isOpen then isOpen = true end
      table.insert(
         self.doors,
         Door:new({
               position = {
                  x = doorX,
                  y = door.y,
               },
               destination = door.destination,
               isOpen = door.isOpen,
               color = door.color,
         })
      )
      if door.initial then
         self.initialPlayerPosition = { x = door.x, y = door.y }
      end
   end
end

return Level

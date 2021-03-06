local Camera = require 'camera'
local Collectible = require 'collectible'
local Colors = require 'colors'
local Craft = require 'craft'
local Door = require 'door'
local Goal = require 'goal'
local LevelData = require 'leveldata'
local Particles = require 'particles'
local Pond = require 'pond'
local SharedState = require 'sharedstate'

local Level = {
   segments = {},
   ponds = {},
   collectibles = {},
   doors = {},
   size = { width = 0, height = 0 },
   backgroundSegments = {},
   goal = nil,
   palettes = nil,
   
   numCollectiblesHeld = 0,
   initialPlayerPosition = {},
   restartTimer = 0,

   Event = {
      NONE = 0,
      COLLECT = 1,
      PLAYER_DEATH = 2,
      ENTER_DOOR = 3,
      GAME_OVER = 4,
      RESTART = 5,
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
   if SharedState.environment.windy then
      if math.random() < 0.2 then
         Particles:wind()
      end
   end
   if self.goal then
      self.goal:update(dt)
   end
   if self.restartTimer > 0 then
      self.restartTimer = self.restartTimer - dt
      if self.restartTimer <= 0 then
         self.restartTimer = -1
      end
   end
   Particles:update(dt)
end

function Level:interactWith(craft)
   -- goal
   if self.goal then
      local result = self.goal:interactWith(craft)
      if result == Goal.Event.REACHED then
         craft.state = craft.states.HIDDEN
         Goal:animate(craft)
      elseif result == Goal.Event.FINISHED then
         return self.Event.GAME_OVER
      end
   end

   -- death timer
   if craft.state == craft.states.HIDDEN then
      if self.restartTimer < 0 then
         self.restartTimer = 0
         return self.Event.RESTART
      else
         -- preclude other interaction
         return self.Event.NONE
      end
   end

   -- terrain
   if self:collidesWith(craft.position.x, craft.position.y) then
      self:_onPlayerDeath(craft)
      return self.Event.PLAYER_DEATH
   end

   -- ponds
   for index, pond in pairs(self.ponds) do
      local result = pond:interactWith(craft)
      if result == Pond.Event.PLAYER_DEATH then
         self:_onPlayerDeath(craft)
         return self.Event.PLAYER_DEATH
      end
   end

   -- collectibles
   for index, collectible in pairs(self.collectibles) do
      local result = collectible:interactWith(craft)
      if result == Collectible.Event.COLLECT then
         self.collectibles[index] = nil
         self:_onPlayerCollect(collectible)
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
   local cameraPosition = Camera:getPosition()
   love.graphics.push()
   love.graphics.translate(-cameraPosition.x, -cameraPosition.y)
   for index, pond in pairs(self.ponds) do
      pond:draw()
   end
   for index, collectible in pairs(self.collectibles) do
      collectible:draw()
   end
   for index, door in pairs(self.doors) do
      door:draw(self.palettes[1])
   end
   if self.goal then
      self.goal:draw()
   end
   Craft:draw(self.palettes[1])
   Colors.useColorInterpPalettes(self.palettes, Camera:getXInterp(), Colors.Value.TERRAIN)
   self:_drawSegments(self.segments, 0, self:getGroundBaseline(), _GRID_SIZE)
   Particles:draw()
   love.graphics.pop()
   Particles:drawForeground()
   if self.goal then
      self.goal:drawForeground()
   end
end

function Level:drawBackground()
   local cameraPosition = Camera:getPosition()
   self:drawSky()
   love.graphics.push()
   love.graphics.translate(-cameraPosition.x * 0.85, -cameraPosition.y * 0.9)
   self:_drawBackgroundLayer()
   love.graphics.pop()
end

function Level:_drawSegments(segments, xStart, yStart, gridSize)
   local prevHeight
   local xx, yy = xStart, yStart
   for index, height in pairs(segments) do
      if prevHeight then
         love.graphics.polygon(
            'fill',
            xx - gridSize, yy - prevHeight * gridSize,
            xx, yy - height * gridSize,
            xx, SharedState.viewport.height,
            xx - gridSize, SharedState.viewport.height
         )
      end
      prevHeight = height
      xx = xx + gridSize
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

function Level:drawSky()
   local color1 = { r = 87, g = 136, b = 98 }
   local color2 = { r = 227, g = 207, b = 126 }
   local numRegions = 12
   local regionSize = SharedState.viewport.height / numRegions
   for i = 0, numRegions - 1 do
      local interp = i / (numRegions - 1)
      Colors.useInterpColorInterpPalettes(
         self.palettes, Camera:getXInterp(),
         Colors.Value.SKYTOP, Colors.Value.SKYBOTTOM, interp
      )
      love.graphics.rectangle(
         'fill',
         0, i * regionSize,
         SharedState.viewport.width, regionSize
      )
   end
end

function Level:_drawBackgroundLayer()
   Colors.useColorInterpPalettes(self.palettes, Camera:getXInterp(), Colors.Value.BACKGROUND)
   self:_drawSegments(self.backgroundSegments, 0, self:getGroundBaseline() - 32, _GRID_SIZE * 0.8)
end

function Level:_onPlayerDeath(craft)
   Particles:playerDeath(craft)
   craft.state = craft.states.HIDDEN
   self.restartTimer = 1
end

function Level:_onPlayerCollect(collectible)
   if collectible.shape == Collectible.Shapes.BORING then
      self.numCollectiblesHeld = self.numCollectiblesHeld + 1
   elseif collectible.shape == Collectible.Shapes.SPECIAL then
      SharedState.boost = 1
   elseif collectible.shape == Collectible.Shapes.UPGRADE then
      SharedState.isBoostEnabled = true
      Particles:doorOpened(collectible)
   end
   if self.levelId == 1 then
      if self.numCollectiblesHeld == 1 then
         self.doors[2]:open()
      end
   elseif self.levelId == 2 then
      if self.numCollectiblesHeld == 4 then
         self.doors[2]:open()
      end
   elseif self.levelId == 3 then
      if self.numCollectiblesHeld == 3 then
         self.doors[2]:open()
      end
   elseif self.levelId == 5 then
      if self.numCollectiblesHeld == 6 then
         self.doors[2]:open()
      end
      if collectible.shape == Collectible.Shapes.SPECIAL then
         self.doors[1]:open()
      end
   elseif self.levelId == 6 then
      if self.numCollectiblesHeld == 2 then
         self.doors[2]:open()
      end
      if collectible.shape == Collectible.Shapes.SPECIAL then
         self.doors[1]:open()
      end
   elseif self.levelId == 7 then
      self.doors[1]:open()
   end
end

function Level:loadLevelData(data, initialDoorIndex)
   self.levelId = data.id
   self.palettes = data.palettes or { Colors.Palette.START }
   initialDoorIndex = initialDoorIndex or 1

   if data.windy then
      SharedState:setEnvironment({ windy = true })
   else
      SharedState:setEnvironment({ windy = false })
   end

   if data.background then
      self.backgroundSegments = data.background
   else
      self.backgroundSegments = LevelData.DefaultBackground
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
      local x, y, shape
      if collectible.index then
         x = collectible.index * _GRID_SIZE
         y = self:_getHeightAtX(x) - 6
         if collectible.hover then
            y = y - collectible.hover
         end
      end
      if collectible.shape then
         shape = collectible.shape
      else
         shape = Collectible.Shapes.BORING
      end
      local isCollected = (shape == Collectible.Shapes.BORING and SharedState.isBoostEnabled)
      if not isCollected then
         table.insert(
            self.collectibles,
            Collectible:new({
                  position = {
                     x = x,
                     y = y,
                  },
                  shape = shape,
            })
         )
      end
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
      if index == initialDoorIndex then
         self.initialPlayerPosition = { x = doorX, y = door.y }
      end
   end

   if data.goal then
      local x, y
      x = data.goal.index * _GRID_SIZE
      y = self:_getHeightAtX(x)
      self.goal = Goal:new({
            position = {
               x = x,
               y = y,
            },
      })
   else
      self.goal = nil
   end
end

return Level

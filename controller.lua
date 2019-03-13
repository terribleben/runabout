local Camera = require 'camera'
local Craft = require 'craft'
local Level = require 'level'
local LevelData = require 'leveldata'
local SharedState = require 'sharedstate'

local Controller = {
   _currentLevelId = 1,
}

function Controller:reset()
   self:_loadLevel(self._currentLevelId)
end

function Controller:draw()
   Level:drawBackground()
   Level:draw()
   love.graphics.setColor(227 / 255, 87 / 255, 91 / 255, 1)
   love.graphics.rectangle('line', 12, 12, 128, 12)
   love.graphics.rectangle('fill', 12, 12, 128 * Craft.fuel, 12)
   if SharedState.isBoostEnabled then
      love.graphics.setColor(0, 1, 1, 1)
      love.graphics.rectangle('line', 12, 36, 128, 12)
      love.graphics.rectangle('fill', 12, 36, 128 * SharedState.boost, 12)
   end
end

function Controller:update(dt)
   Craft:update(dt)
   Level:update(dt)
   if Craft.position.x > Level.size.width then
      Craft.position.x = Level.size.width
   end
   if Craft.position.x < 0 then
      Craft.position.x = 0
   end
   Camera:update(Level, Craft.position, dt)
   local event, data = Level:interactWith(Craft)
   if event == Level.Event.PLAYER_DEATH then
      self:_loadLevel(self._currentLevelId)
   elseif event == Level.Event.ENTER_DOOR then
      self:_loadLevel(data.destination)
   end
end

function Controller:_loadLevel(levelId)
   Level:reset()
   local levelToLoad = LevelData.levels[levelId];
   Level:loadLevelData(levelToLoad)
   self._currentLevelId = levelId
   Craft:reset()
   Craft.position = {
      x = Level.initialPlayerPosition.x,
      y = Level.initialPlayerPosition.y,
   }
   Camera:update(Level, Craft.position, 0)
end

return Controller

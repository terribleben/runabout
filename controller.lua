local Camera = require 'camera'
local Craft = require 'craft'
local Level = require 'level'
local LevelData = require 'leveldata'
local Menu = require 'menu'
local SharedState = require 'sharedstate'

local Controller = {
   state = 1,
   _stateLastChanged = 0,
   
   _currentLevelId = 1,
   _currentInitialDoorIndex = 1,

   States = {
      INIT = 0,
      PLAY = 1,
      END = 2,
   },
}

function Controller:reset()
   self:_setState(self.States.INIT)
   self:_loadLevel(self._currentLevelId, self._currentInitialDoorIndex)
end

function Controller:draw()
   if self.state == self.States.INIT then
      Menu:draw()
   elseif self.state == self.States.PLAY then
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
   elseif self.state == self.States.END then
      Level:drawBackground()
      love.graphics.setColor(1, 1, 1, 0.5)
      love.graphics.rectangle('fill', 100, 100, SharedState.viewport.width - 200, SharedState.viewport.height - 200)
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.print('TODO: you win', 200, 200)
      love.graphics.print('space to return to menu', 200, 248)
   end
end

function Controller:update(dt)
   if self.state == self.States.PLAY then
      if self._freeze == true then
         return
      end
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
         self:_loadLevel(self._currentLevelId, self._currentInitialDoorIndex)
      elseif event == Level.Event.ENTER_DOOR then
         self:_loadLevel(data.destination.levelId, data.destination.door)
      elseif event == Level.Event.GAME_OVER then
         self:_setState(self.States.END)
      end
   end
end

function Controller:keypressed(key)
   if key == 'j' then
      self._freeze = true
   end

   if self.state == self.States.PLAY then return end

   local timeSinceChange = love.timer.getTime() - self._stateLastChanged
   if timeSinceChange > 0.5 and key == 'space' then
      if self.state == self.States.INIT then
         self:_setState(self.States.PLAY)
         self:_loadLevel(1, 1)
      elseif self.state == self.States.END then
         self:_setState(self.States.INIT)
         SharedState:reset()
      end
   end
end

function Controller:_setState(state)
   self.state = state
   self._stateLastChanged = love.timer.getTime()
end

function Controller:_loadLevel(levelId, doorIndex)
   Level:reset()
   SharedState.boost = 0
   local levelToLoad = LevelData.levels[levelId];
   Level:loadLevelData(levelToLoad, doorIndex)
   self._currentLevelId = levelId
   self._currentInitialDoorIndex = doorIndex
   Craft:reset()
   Craft.position = {
      x = Level.initialPlayerPosition.x,
      y = Level.initialPlayerPosition.y,
   }
   Camera:update(Level, Craft.position, 0)
end

return Controller

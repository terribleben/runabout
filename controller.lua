local Camera = require 'camera'
local Colors = require 'colors'
local Craft = require 'craft'
local GameOver = require 'gameover'
local HiScore = require 'hiscore'
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
   HiScore:load()
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
      self:_maybeDrawTimer()
   elseif self.state == self.States.END then
      GameOver:draw()
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
         Camera:shake()
      elseif event == Level.Event.RESTART then
         self:_loadLevel(self._currentLevelId, self._currentInitialDoorIndex)
      elseif event == Level.Event.ENTER_DOOR then
         self:_loadLevel(data.destination.levelId, data.destination.door)
      elseif event == Level.Event.GAME_OVER then
         SharedState.timer.finished = love.timer.getTime()
         HiScore:maybeSave(SharedState.timer.finished - SharedState.timer.started)
         self:_setState(self.States.END)
      end
   elseif self.state == self.States.END then
      GameOver:update(dt)
   end
end

function Controller:keypressed(key)
   if key == 'j' then
      self._freeze = true
   end

   if self.state == self.States.PLAY then return end

   local timeSinceChange = love.timer.getTime() - self._stateLastChanged
   if timeSinceChange > 1.0 and key == 'space' then
      if self.state == self.States.INIT then
         self:_setState(self.States.PLAY)
         SharedState.timer.started = love.timer.getTime()
         SharedState.timer.prevBest = HiScore:get()
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

function Controller:_maybeDrawTimer()
   if SharedState.timer.prevBest > 0 then
      local currentTime = love.timer.getTime() - SharedState.timer.started
      if currentTime > SharedState.timer.prevBest then
         local timerStr = '+ ' .. HiScore:formatTime(currentTime - SharedState.timer.prevBest)
         local mediumFont = SharedState.font.medium
         love.graphics.setFont(mediumFont)
         Colors.useColor(Level.palettes[1], Colors.Value.SKYTOP)
         local width = mediumFont:getWidth(timerStr)
         love.graphics.print(
            timerStr,
            SharedState.viewport.width - width - 16,
            SharedState.viewport.height - 16 + (-mediumFont:getHeight() * 0.5)
         )
     end
   end
end

return Controller

local Colors = require 'colors'
local HiScore = require 'hiscore'
local Level = require 'level'
local SharedState = require 'sharedstate'

local GameOver = {
   _transitionTimer = 2
}

local _GAMEOVER = 'game over'
local _RETURN = 'space to return to menu'
local _TIME = 'time: '

function GameOver:update(dt)
   if self._transitionTimer > 0 then
      self._transitionTimer = self._transitionTimer - dt
   end
end

function GameOver:draw()
   Level:drawSky()

   -- title
   Colors.useColor(Colors.Palette.START, Colors.Value.SKYBOTTOM)
   local bigFont = SharedState.font.big
   love.graphics.setFont(bigFont)
   local titleWidth = bigFont:getWidth(_GAMEOVER)
   love.graphics.print(
      _GAMEOVER,
      (SharedState.viewport.width * 0.5) - (titleWidth * 0.5),
      100 + (-bigFont:getHeight() * 0.5)
   )

   -- score
   local mediumFont = SharedState.font.medium
   love.graphics.setFont(mediumFont)

   Colors.useColor(Colors.Palette.START, Colors.Value.TEXT)
   local scoreStr = _TIME .. HiScore:formatTime(SharedState.timer.finished - SharedState.timer.started)
   local scoreWidth = mediumFont:getWidth(scoreStr)
   love.graphics.print(
      scoreStr,
      (SharedState.viewport.width * 0.5) - (scoreWidth * 0.5),
      264 + (-mediumFont:getHeight() * 0.5)
   )

   -- return
   if math.floor(love.timer.getTime() * 6) % 2 == 1 then
      Colors.useColor(Colors.Palette.START, Colors.Value.TEXT)
   else
      love.graphics.setColor(1, 1, 1, 1)
   end
   
   local width = mediumFont:getWidth(_RETURN)
   love.graphics.print(
      _RETURN,
      (SharedState.viewport.width * 0.5) - (width * 0.5),
      SharedState.viewport.height - 78 + (-mediumFont:getHeight() * 0.5)
   )

   if self._transitionTimer > 0 then
      local alpha = (self._transitionTimer / 2)
      love.graphics.setColor(1, 1, 1, alpha)
      love.graphics.rectangle('fill', 0, 0, SharedState.viewport.width, SharedState.viewport.height)
   end
end

return GameOver

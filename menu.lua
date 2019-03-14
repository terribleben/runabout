local Colors = require 'colors'
local Level = require 'level'
local SharedState = require 'sharedstate'

local Menu = {}

local _TITLE = 'runabout'
local _INSTRUCTIONS = {
   'up to thrust',
   'left/right to turn',
}
local _START = 'space to start'

function Menu:draw()
   Level:drawSky()

   -- title
   Colors.useColor(Colors.Palette.START, Colors.Value.SKYBOTTOM)
   local bigFont = SharedState.font.big
   love.graphics.setFont(bigFont)
   local titleWidth = bigFont:getWidth(_TITLE)
   love.graphics.print(
      _TITLE,
      (SharedState.viewport.width * 0.5) - (titleWidth * 0.5),
      100 + (-bigFont:getHeight() * 0.5)
   )

   -- instructions
   local mediumFont = SharedState.font.medium
   love.graphics.setFont(mediumFont)
   for index, str in pairs(_INSTRUCTIONS) do
      local width = mediumFont:getWidth(str)
      love.graphics.print(
         str,
         (SharedState.viewport.width * 0.5) - (width * 0.5),
         148 + (index * 32) + (-mediumFont:getHeight() * 0.5)
      )
   end

   -- start
   if math.floor(love.timer.getTime() * 6) % 2 == 1 then
      Colors.useColor(Colors.Palette.START, Colors.Value.TEXT)
   else
      love.graphics.setColor(1, 1, 1, 1)
   end
   
   local width = mediumFont:getWidth(_START)
   love.graphics.print(
      _START,
      (SharedState.viewport.width * 0.5) - (width * 0.5),
      SharedState.viewport.height - 78 + (-mediumFont:getHeight() * 0.5)
   )
end

return Menu

local Controller = require 'controller'
local SharedState = require 'sharedstate'

G_VIEWPORT_BUFFER = 800

function love.load()
   _loadFont()
   _reset()
end

function love.draw()
   love.graphics.push()
   -- transform to viewport coords
   love.graphics.translate(SharedState.screen.width * 0.5, SharedState.screen.height * 0.5)
   love.graphics.translate(SharedState.viewport.x, SharedState.viewport.y)
   Controller:draw()
   _drawViewportBorder()
   love.graphics.pop()
end

function love.update(dt)
   Controller:update(dt)
end

function _reset()
   SharedState:reset()
   Controller:reset()
end

function _drawViewportBorder()
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.rectangle(
      'line',
      0, 0,
      SharedState.viewport.width, SharedState.viewport.height
   )
   love.graphics.setColor(0, 0, 0, 1)
   love.graphics.rectangle(
      'fill',
      -G_VIEWPORT_BUFFER, 0,
      G_VIEWPORT_BUFFER, SharedState.viewport.height
   )
   love.graphics.rectangle(
      'fill',
      SharedState.viewport.width, 0,
      G_VIEWPORT_BUFFER, SharedState.viewport.height
   )
   love.graphics.rectangle(
      'fill',
      -G_VIEWPORT_BUFFER, -G_VIEWPORT_BUFFER,
      SharedState.viewport.width + 2.0 * G_VIEWPORT_BUFFER, G_VIEWPORT_BUFFER
   )
   love.graphics.rectangle(
      'fill',
      -G_VIEWPORT_BUFFER, SharedState.viewport.height,
      SharedState.viewport.width + 2.0 * G_VIEWPORT_BUFFER, G_VIEWPORT_BUFFER
   )
end

function love.keypressed(...)
   Controller:keypressed(...)
end

function _loadFont()
   SharedState.font = {}
   local fontSizes = {
      small = 16,
      medium = 24,
      big = 72,
   }
   for name, size in pairs(fontSizes) do
      SharedState.font[name] = love.graphics.newFont("x14y24pxHeadUpDaisy.ttf", size)
   end
end

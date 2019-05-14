local SharedState = {
   screen = { width = 0, height = 0 },
   viewport = { x = 0, y = 0, width = 0, height = 0 },
   environment = {
      windy = false,
   },
   isBoostEnabled = false,
   boost = 0,
   font = {},
   timer = {
      started = 0,
      finished = 0,
      prevBest = 0, -- compare against this while playing
   },
}

function SharedState:reset()
   self:_reset()
end

function SharedState:_reset()
   local width, height, flags = love.window.getMode()
   self.screen.width = width
   self.screen.height = height
   self.viewport.width = math.min(800, self.screen.width)
   self.viewport.height = math.min(600, self.screen.height)
   self.viewport.x = self.viewport.width * -0.5
   self.viewport.y = self.viewport.height * -0.5
   self.environment = { windy = false }
   self.isBoostEnabled = false
   self.boost = 0
   self.timer = {
      started = 0,
      finished = 0,
      prevBest = 0,
   }
end

function SharedState:setEnvironment(environment)
   self.environment = environment
end

return SharedState

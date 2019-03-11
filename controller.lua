local Craft = require 'craft'

local Controller = {
}

function Controller:reset()
end

function Controller:draw()
   Craft:draw()
end

function Controller:update(dt)
   Craft:update(dt)
end

return Controller

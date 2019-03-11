local Craft = require 'craft'
local Level = require 'level'

local Controller = {
}

function Controller:reset()
   Level:reset()
end

function Controller:draw()
   Craft:draw()
   Level:draw()
end

function Controller:update(dt)
   Craft:update(dt)
end

return Controller

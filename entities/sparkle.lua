local Sparkle = {}
Sparkle.__index = Sparkle

local validation = require("utils.validation")

function Sparkle.new(x, y)
    local self = setmetatable({}, Sparkle)
    
    if not validation.validateCoords(x, y, "Sparkle.new") then
        return nil
    end
    
    self.x = x + (love.math.random() - 0.5) * 40
    self.y = y + (love.math.random() - 0.5) * 40
    self.vx = (love.math.random() - 0.5) * 200
    self.vy = (love.math.random() - 0.5) * 200
    self.life = 1.0
    self.size = love.math.random() * 3 + 1
    self.color = love.math.random(5)
    
    return self
end

function Sparkle:update(dt)
    if not validation.validateCoords(self.x, self.y, "sparkle position") then
        return false
    end
    
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.vx = self.vx * 0.95
    self.vy = self.vy * 0.95
    self.life = self.life - dt * 2
    
    if self.life <= 0 or not validation.validateCoords(self.x, self.y, "sparkle after update") then
        return false
    end
    
    return true
end

return Sparkle
local Particle = {}
Particle.__index = Particle

local validation = require("utils.validation")

function Particle.new(x, y, vx, vy, life, size, color)
    local self = setmetatable({}, Particle)
    
    if not validation.validateCoords(x, y, "Particle.new") then
        return nil
    end
    if not validation.isValidNumber(vx) then vx = 0 end
    if not validation.isValidNumber(vy) then vy = 0 end
    if not validation.isValidNumber(life) or life <= 0 then life = 1 end
    if not validation.isValidNumber(size) or size <= 0 then size = 2 end
    
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.life = life
    self.maxLife = life
    self.size = size
    self.color = color or 1
    self.gravity = love.math.random() * 50 + 25
    
    return self
end

function Particle:update(dt)
    if not validation.isValidNumber(dt) or dt < 0 or dt > 1 then
        return false
    end
    
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.vy = self.vy + self.gravity * dt
    self.life = self.life - dt
    
    if not validation.validateCoords(self.x, self.y, "particle after update") or self.life <= 0 then
        return false
    end
    
    return true
end

function Particle:getAlpha()
    return self.life / self.maxLife
end

return Particle
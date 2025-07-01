local Wave = {}
Wave.__index = Wave

local validation = require("utils.validation")

function Wave.new(centerX, centerY, maxRadius, speed, color)
    local self = setmetatable({}, Wave)
    
    if not validation.validateCoords(centerX, centerY, "Wave.new") then
        return nil
    end
    if not validation.isValidNumber(maxRadius) or maxRadius <= 0 then maxRadius = 100 end
    if not validation.isValidNumber(speed) or speed <= 0 then speed = 100 end
    
    self.centerX = centerX
    self.centerY = centerY
    self.radius = 0
    self.maxRadius = maxRadius
    self.speed = speed
    self.color = color or 1
    self.alpha = 1.0
    
    return self
end

function Wave:update(dt)
    self.radius = self.radius + self.speed * dt
    self.alpha = 1 - (self.radius / self.maxRadius)
    
    return self.radius < self.maxRadius and self.alpha > 0
end

return Wave
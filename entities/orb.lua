local Orb = {}
Orb.__index = Orb

local validation = require("utils.validation")

function Orb.new(x, y, vx, vy, size, color)
    local self = setmetatable({}, Orb)
    
    if not validation.validateCoords(x, y, "Orb.new") then
        x, y = love.graphics.getWidth()/2, love.graphics.getHeight()/2
    end
    if not validation.isValidNumber(vx) then vx = 0 end
    if not validation.isValidNumber(vy) then vy = 0 end
    if not validation.isValidNumber(size) or size <= 0 then size = 20 end
    
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.size = size
    self.color = color or 1
    self.trail = {}
    self.life = 1.0
    self.pulse = love.math.random() * math.pi * 2
    self.rotation = 0
    self.rotationSpeed = love.math.random() * 2 - 1
    
    return self
end

function Orb:update(dt, time, width, height, debug)
    if not validation.isValidNumber(dt) or dt < 0 or dt > 1 then
        return
    end
    
    local sineX = math.sin(time * 2 + self.pulse) * 30 * dt
    local cosY = math.cos(time * 1.5 + self.pulse) * 20 * dt
    
    if validation.isValidNumber(sineX) and validation.isValidNumber(cosY) then
        self.x = self.x + self.vx * dt + sineX
        self.y = self.y + self.vy * dt + cosY
    end
    
    local wrapped = false
    if self.x < -self.size then 
        self.x = width + self.size
        wrapped = true
    end
    if self.x > width + self.size then 
        self.x = -self.size
        wrapped = true
    end
    if self.y < -self.size then 
        self.y = height + self.size
        wrapped = true
    end
    if self.y > height + self.size then 
        self.y = -self.size
        wrapped = true
    end
    
    if wrapped then
        self.trail = {}
    end
    
    if not validation.validateCoords(self.x, self.y, "orb after update", debug) then
        self.x = math.max(-self.size, math.min(width + self.size, self.x))
        self.y = math.max(-self.size, math.min(height + self.size, self.y))
    end
    
    if validation.validateCoords(self.x, self.y, "trail update", debug) then
        table.insert(self.trail, 1, {x = self.x, y = self.y, time = time})
        if #self.trail > 20 then
            table.remove(self.trail)
        end
    end
    
    self.pulse = self.pulse + dt * 3
    self.rotation = self.rotation + self.rotationSpeed * dt
end

function Orb:getPulseSize()
    return self.size + math.sin(self.pulse) * 5
end

function Orb:getDistance(x, y)
    local dx = self.x - x
    local dy = self.y - y
    return math.sqrt(dx * dx + dy * dy)
end

return Orb
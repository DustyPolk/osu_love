local Orb = {}
Orb.__index = Orb

local validation = require("utils.validation")

function Orb.new(x, y, vx, vy, size, color, spawnTime)
    local self = setmetatable({}, Orb)
    
    if not validation.validateCoords(x, y, "Orb.new") then
        x, y = love.graphics.getWidth()/2, love.graphics.getHeight()/2
    end
    if not validation.isValidNumber(vx) then vx = 0 end
    if not validation.isValidNumber(vy) then vy = 0 end
    if not validation.isValidNumber(size) or size <= 0 then size = 20 end
    
    local config = require("game.config")
    
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
    
    -- OSU!-style timing properties
    self.spawnTime = spawnTime or 0
    self.activeTime = self.spawnTime + config.orbs.spawnTime
    self.expireTime = self.activeTime + config.orbs.hitWindow
    self.state = "spawning"  -- "spawning", "active", "missed", "hit"
    self.alpha = 0
    self.isClickable = false
    
    return self
end

function Orb:update(dt, time, width, height, debug)
    if not validation.isValidNumber(dt) or dt < 0 or dt > 1 then
        return true  -- Continue existing
    end
    
    local config = require("game.config")
    
    -- Update timing state
    if self.state == "spawning" then
        if time >= self.activeTime then
            self.state = "active"
            self.isClickable = true
        else
            -- Fade in during spawn time
            local fadeProgress = math.max(0, (time - self.spawnTime) / config.orbs.fadeInTime)
            self.alpha = math.min(1, fadeProgress)
        end
    elseif self.state == "active" then
        self.alpha = 1
        if time >= self.expireTime then
            self.state = "missed"
            self.isClickable = false
        end
    elseif self.state == "missed" then
        -- Fade out when missed
        local fadeOutProgress = (time - self.expireTime) / config.orbs.fadeOutTime
        self.alpha = math.max(0, 1 - fadeOutProgress)
        if self.alpha <= 0 then
            return false  -- Remove orb
        end
    elseif self.state == "hit" then
        return false  -- Remove orb immediately when hit
    end
    
    -- Only move and create trails for active orbs
    if self.state == "active" then
        local sineX = math.sin(time * 2 + self.pulse) * 15 * dt  -- Reduced movement
        local cosY = math.cos(time * 1.5 + self.pulse) * 10 * dt
        
        if validation.isValidNumber(sineX) and validation.isValidNumber(cosY) then
            self.x = self.x + self.vx * dt + sineX
            self.y = self.y + self.vy * dt + cosY
        end
        
        -- Keep orbs on screen (no wrapping for OSU! style)
        self.x = math.max(self.size, math.min(width - self.size, self.x))
        self.y = math.max(self.size, math.min(height - self.size, self.y))
        
        if validation.validateCoords(self.x, self.y, "trail update", debug) then
            table.insert(self.trail, 1, {x = self.x, y = self.y, time = time})
            if #self.trail > 10 then  -- Shorter trails for cleaner look
                table.remove(self.trail)
            end
        end
    end
    
    self.pulse = self.pulse + dt * 3
    self.rotation = self.rotation + self.rotationSpeed * dt
    
    return true  -- Continue existing
end

function Orb:getPulseSize()
    if self.state == "active" then
        return self.size + math.sin(self.pulse) * 3  -- More subtle pulse for active orbs
    else
        return self.size + math.sin(self.pulse) * 1  -- Minimal pulse for non-active
    end
end

function Orb:getDistance(x, y)
    local dx = self.x - x
    local dy = self.y - y
    return math.sqrt(dx * dx + dy * dy)
end

function Orb:hit()
    self.state = "hit"
    self.isClickable = false
end

function Orb:isActive()
    return self.state == "active" and self.isClickable
end

function Orb:getAlpha()
    return self.alpha
end

return Orb
local HitEffect = {}
HitEffect.__index = HitEffect

function HitEffect.new(x, y, hitType, points)
    local self = setmetatable({}, HitEffect)
    
    self.x = x
    self.y = y
    self.hitType = hitType
    self.points = points
    self.life = 1.0
    self.size = 20
    self.alpha = 1.0
    
    return self
end

function HitEffect:update(dt)
    self.life = self.life - dt * 2
    self.alpha = self.life
    self.size = self.size + dt * 30
    
    return self.life > 0
end

return HitEffect
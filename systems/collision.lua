local collision = {}

local config = require("game.config")
local state = require("game.state")
local HitEffect = require("entities.hit_effect")
local Particle = require("entities.particle")

function collision.checkOrbHit(mouseX, mouseY, orbs, gameState, particles, hitEffects)
    if not orbs or #orbs == 0 then
        return false
    end
    
    for i = #orbs, 1, -1 do
        local orb = orbs[i]
        if orb and orb:isActive() then  -- Only check active orbs
            local distance = orb:getDistance(mouseX, mouseY)
            local orbRadius = orb:getPulseSize()
            
            if distance <= orbRadius then
                local accuracyRatio = 1 - (distance / orbRadius)
                local hitType, points
                
                if accuracyRatio > config.hitAccuracy.perfect then
                    hitType = "PERFECT!"
                    points = config.scoring.perfect
                elseif accuracyRatio > config.hitAccuracy.good then
                    hitType = "GOOD"
                    points = config.scoring.good
                else
                    hitType = "OKAY"
                    points = config.scoring.okay
                end
                
                state.recordHit(gameState)
                local finalPoints = state.addScore(gameState, points, hitType)
                
                table.insert(hitEffects, HitEffect.new(orb.x, orb.y, hitType, finalPoints))
                
                for j = 1, config.particles.explosionCount do
                    local angle = (j / config.particles.explosionCount) * math.pi * 2
                    local speed = config.particles.minSpeed + love.math.random() * (config.particles.maxSpeed - config.particles.minSpeed)
                    local particle = Particle.new(
                        orb.x + math.cos(angle) * 10,
                        orb.y + math.sin(angle) * 10,
                        math.cos(angle) * speed,
                        math.sin(angle) * speed,
                        config.particles.minLife + love.math.random() * (config.particles.maxLife - config.particles.minLife),
                        config.particles.minSize + love.math.random() * (config.particles.maxSize - config.particles.minSize),
                        orb.color
                    )
                    if particle then
                        table.insert(particles, particle)
                    end
                end
                
                -- Mark orb as hit instead of removing it directly
                orb:hit()
                
                return true
            end
        end
    end
    return false
end

function collision.handleMiss(x, y, gameState, hitEffects)
    state.recordMiss(gameState)
    table.insert(hitEffects, HitEffect.new(x, y, "MISS", 0))
end

return collision
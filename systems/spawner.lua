local spawner = {}

local config = require("game.config")
local Orb = require("entities.orb")
local Particle = require("entities.particle")

function spawner.createRandomOrb(width, height)
    return Orb.new(
        love.math.random() * width,
        love.math.random() * height,
        (love.math.random() - 0.5) * 100,
        (love.math.random() - 0.5) * 100,
        love.math.random() * (config.orbs.maxSize - config.orbs.minSize) + config.orbs.minSize,
        love.math.random(5)
    )
end

function spawner.maintainOrbCount(orbs, width, height)
    while #orbs < config.orbs.minCount do
        table.insert(orbs, spawner.createRandomOrb(width, height))
    end
end

function spawner.spawnOrbParticles(orb, particles)
    if love.math.random() < 0.1 then
        for j = 1, 2 do
            local particle = Particle.new(
                orb.x + (love.math.random() - 0.5) * orb.size,
                orb.y + (love.math.random() - 0.5) * orb.size,
                (love.math.random() - 0.5) * 50,
                (love.math.random() - 0.5) * 50,
                love.math.random() * 2 + 1,
                love.math.random() * 3 + 1,
                orb.color
            )
            if particle then
                table.insert(particles, particle)
            end
        end
    end
end

return spawner
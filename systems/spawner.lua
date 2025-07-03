local spawner = {}

local config = require("game.config")
local Orb = require("entities.orb")
local Particle = require("entities.particle")

-- Pattern spawning state
local lastPatternTime = 0
local nextOrbTime = math.huge  -- Start with impossible time to prevent premature spawning
local currentGroup = {}
local groupIndex = 1

function spawner.createTimedOrb(x, y, spawnTime, width, height)
    -- Create stationary orbs for OSU! style gameplay
    return Orb.new(
        x, y,
        0, 0,  -- No initial velocity for positioned orbs
        love.math.random() * (config.orbs.maxSize - config.orbs.minSize) + config.orbs.minSize,
        love.math.random(5),
        spawnTime
    )
end

function spawner.generateOrbPattern(time, width, height)
    local groupSize = love.math.random(config.patterns.groupSize.min, config.patterns.groupSize.max)
    local pattern = {}
    
    -- Choose pattern type (authentic OSU! patterns)
    local patternTypes = {"linear", "arc", "triangle", "cross", "circle"}
    local patternType = patternTypes[love.math.random(#patternTypes)]
    
    -- Generate center point for pattern (safe margin from edges)
    local centerX = love.math.random(100, width - 100)
    local centerY = love.math.random(100, height - 100)
    
    if patternType == "linear" then
        pattern = spawner.generateLinearPattern(centerX, centerY, groupSize, time)
    elseif patternType == "arc" then
        pattern = spawner.generateArcPattern(centerX, centerY, groupSize, time)
    elseif patternType == "triangle" then
        pattern = spawner.generateTrianglePattern(centerX, centerY, math.min(groupSize, 3), time)
    elseif patternType == "cross" then
        pattern = spawner.generateCrossPattern(centerX, centerY, math.min(groupSize, 4), time)
    elseif patternType == "circle" then
        pattern = spawner.generateCirclePattern(centerX, centerY, groupSize, time)
    end
    
    return pattern
end

function spawner.generateLinearPattern(centerX, centerY, groupSize, time)
    local pattern = {}
    local angle = love.math.random() * math.pi * 2  -- Random direction
    local spacing = 80  -- Distance between orbs
    
    for i = 1, groupSize do
        local offset = (i - (groupSize + 1) / 2) * spacing
        local x = centerX + math.cos(angle) * offset
        local y = centerY + math.sin(angle) * offset
        
        local orbSpawnTime = time + (i - 1) * config.patterns.orbSpacing
        table.insert(pattern, {x = x, y = y, spawnTime = orbSpawnTime})
    end
    
    return pattern
end

function spawner.generateArcPattern(centerX, centerY, groupSize, time)
    local pattern = {}
    local radius = 120
    local startAngle = love.math.random() * math.pi * 2
    local arcSpan = math.pi / 2  -- 90 degree arc
    
    for i = 1, groupSize do
        local angleProgress = (i - 1) / math.max(1, groupSize - 1)
        local angle = startAngle + angleProgress * arcSpan
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        local orbSpawnTime = time + (i - 1) * config.patterns.orbSpacing
        table.insert(pattern, {x = x, y = y, spawnTime = orbSpawnTime})
    end
    
    return pattern
end

function spawner.generateTrianglePattern(centerX, centerY, groupSize, time)
    local pattern = {}
    local size = 100
    
    -- Triangle vertices
    local positions = {
        {centerX, centerY - size * 0.6},              -- Top
        {centerX - size * 0.5, centerY + size * 0.3}, -- Bottom left
        {centerX + size * 0.5, centerY + size * 0.3}  -- Bottom right
    }
    
    for i = 1, math.min(groupSize, 3) do
        local orbSpawnTime = time + (i - 1) * config.patterns.orbSpacing
        table.insert(pattern, {x = positions[i][1], y = positions[i][2], spawnTime = orbSpawnTime})
    end
    
    return pattern
end

function spawner.generateCrossPattern(centerX, centerY, groupSize, time)
    local pattern = {}
    local size = 80
    
    -- Cross positions: center, up, right, down, left
    local positions = {
        {centerX, centerY},           -- Center
        {centerX, centerY - size},    -- Up
        {centerX + size, centerY},    -- Right
        {centerX, centerY + size}     -- Down
    }
    
    for i = 1, math.min(groupSize, 4) do
        local orbSpawnTime = time + (i - 1) * config.patterns.orbSpacing
        table.insert(pattern, {x = positions[i][1], y = positions[i][2], spawnTime = orbSpawnTime})
    end
    
    return pattern
end

function spawner.generateCirclePattern(centerX, centerY, groupSize, time)
    local pattern = {}
    local radius = 100
    
    for i = 1, groupSize do
        local angle = (i - 1) * (2 * math.pi / groupSize)
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        local orbSpawnTime = time + (i - 1) * config.patterns.orbSpacing
        table.insert(pattern, {x = x, y = y, spawnTime = orbSpawnTime})
    end
    
    return pattern
end

function spawner.isPositionValid(x, y, existingOrbs, minDistance)
    for _, orb in ipairs(existingOrbs) do
        local dx = x - orb.x
        local dy = y - orb.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < minDistance then
            return false
        end
    end
    return true
end

function spawner.updatePatterns(orbs, time, width, height)
    -- Check if it's time to spawn a new pattern group
    if time - lastPatternTime >= config.patterns.spawnInterval then
        currentGroup = spawner.generateOrbPattern(time, width, height)
        lastPatternTime = time
        groupIndex = 1
        nextOrbTime = currentGroup[1] and currentGroup[1].spawnTime or 0
    end
    
    -- Spawn orbs from current group when their time comes
    if #currentGroup > 0 and groupIndex <= #currentGroup and time >= nextOrbTime then
        local orbData = currentGroup[groupIndex]
        if orbData then  -- Safety check
            local newOrb = spawner.createTimedOrb(orbData.x, orbData.y, orbData.spawnTime, width, height)
            if newOrb then
                table.insert(orbs, newOrb)
            end
        end
        
        groupIndex = groupIndex + 1
        if groupIndex <= #currentGroup then
            nextOrbTime = currentGroup[groupIndex].spawnTime
        else
            nextOrbTime = math.huge  -- No more orbs in this group
        end
    end
end

-- Keep the old function for backwards compatibility but mark as deprecated
function spawner.maintainOrbCount(orbs, width, height)
    -- This function is now deprecated - use updatePatterns instead
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
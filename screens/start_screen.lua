local start_screen = {}

local config = require("game.config")
local colors = require("utils.colors")
local easing = require("utils.easing")
local validation = require("utils.validation")
local spawner = require("systems.spawner")
local renderer = require("systems.renderer")

-- Entity classes
local Orb = require("entities.orb")
local Particle = require("entities.particle")
local Wave = require("entities.wave")
local Sparkle = require("entities.sparkle")

-- Start screen specific state
local startOrbs = {}
local startParticles = {}
local startWaves = {}
local startSparkles = {}
local titlePulse = 0
local promptAlpha = 0
local promptDirection = 1
local lastWaveTime = 0
local lastSparkleTime = 0

function start_screen.init()
    -- Clear any existing entities
    startOrbs = {}
    startParticles = {}
    startWaves = {}
    startSparkles = {}
    
    -- Create background orbs with more dramatic movement
    for i = 1, 7 do
        local orb = Orb.new(
            love.math.random() * config.window.width,
            love.math.random() * config.window.height,
            love.math.random() * 100 - 50,  -- More varied speeds
            love.math.random() * 100 - 50,
            love.math.random() * 30 + 20,   -- Varied sizes
            love.math.random(5)
        )
        if orb then
            -- Give orbs more dramatic rotation
            orb.rotationSpeed = (love.math.random() * 4 - 2) * 2
            table.insert(startOrbs, orb)
        end
    end
    
    titlePulse = 0
    promptAlpha = 0
    promptDirection = 1
    lastWaveTime = 0
    lastSparkleTime = 0
end

function start_screen.update(dt, time)
    -- Update title pulse
    titlePulse = titlePulse + dt * 2
    
    -- Update prompt fade
    promptAlpha = promptAlpha + promptDirection * dt * 1.5
    if promptAlpha > 1 then
        promptAlpha = 1
        promptDirection = -1
    elseif promptAlpha < 0.3 then
        promptAlpha = 0.3
        promptDirection = 1
    end
    
    -- Update orbs with enhanced movement
    for i, orb in ipairs(startOrbs) do
        if orb then
            orb:update(dt, time, config.window.width, config.window.height, false)
            
            -- Spawn more particles for visual effect
            if love.math.random() < 0.3 then
                spawner.spawnOrbParticles(orb, startParticles)
            end
        end
    end
    
    -- Update particles
    for i = #startParticles, 1, -1 do
        local p = startParticles[i]
        if not p or not p:update(dt) then
            table.remove(startParticles, i)
        end
    end
    
    -- Create periodic wave effects from center
    if time - lastWaveTime > 2.5 then
        lastWaveTime = time
        local wave = Wave.new(
            config.window.width / 2,
            config.window.height / 2,
            math.min(config.window.width, config.window.height) * 0.8,
            150,
            love.math.random(5)
        )
        if wave then
            table.insert(startWaves, wave)
        end
    end
    
    -- Update waves
    for i = #startWaves, 1, -1 do
        local wave = startWaves[i]
        if not wave or not wave:update(dt) then
            table.remove(startWaves, i)
        end
    end
    
    -- Create random sparkle bursts
    if time - lastSparkleTime > 1.2 then
        lastSparkleTime = time
        local burstX = love.math.random() * config.window.width
        local burstY = love.math.random() * config.window.height
        
        -- Create burst of sparkles
        for j = 1, 15 do
            local sparkle = Sparkle.new(burstX, burstY)
            if sparkle then
                -- Enhance sparkle movement
                sparkle.vx = sparkle.vx * 2
                sparkle.vy = sparkle.vy * 2
                table.insert(startSparkles, sparkle)
            end
        end
    end
    
    -- Update sparkles
    for i = #startSparkles, 1, -1 do
        local s = startSparkles[i]
        if not s or not s:update(dt) then
            table.remove(startSparkles, i)
        end
    end
    
    -- Keep particle count reasonable
    while #startParticles > 200 do
        table.remove(startParticles, 1)
    end
end

function start_screen.draw(time)
    -- Draw animated background
    renderer.drawBackground(config.window.width, config.window.height, time)
    
    -- Draw waves
    renderer.drawWaves(startWaves)
    
    -- Draw orb trails
    renderer.drawOrbTrails(startOrbs, config.window.width, config.window.height)
    
    -- Draw connections between orbs
    renderer.drawConnections(startOrbs)
    
    -- Draw orbs
    for _, orb in ipairs(startOrbs) do
        renderer.drawOrb(orb)
    end
    
    -- Draw particles
    renderer.drawParticles(startParticles)
    
    -- Draw sparkles
    renderer.drawSparkles(startSparkles)
    
    -- Draw title with pulsing effect
    love.graphics.push()
    love.graphics.translate(config.window.width / 2, config.window.height / 3)
    
    local titleScale = 1 + math.sin(titlePulse) * 0.1
    love.graphics.scale(titleScale, titleScale)
    
    -- Title shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.setFont(love.graphics.newFont(72))
    love.graphics.printf("OSU! LOVE", -300, 4, 600, "center")
    
    -- Title main
    local titleColor = colors.getColor(math.floor(titlePulse / 2) % 5 + 1)
    love.graphics.setColor(titleColor[1], titleColor[2], titleColor[3], 1)
    love.graphics.printf("OSU! LOVE", -300, 0, 600, "center")
    
    love.graphics.pop()
    
    -- Draw subtitle
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
    love.graphics.printf("Orb Destroyer", 0, config.window.height / 2 - 20, config.window.width, "center")
    
    -- Draw prompt with fade effect
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.setColor(1, 1, 1, promptAlpha)
    love.graphics.printf("Click to Start", 0, config.window.height * 0.7, config.window.width, "center")
    
    -- Reset font
    love.graphics.setFont(love.graphics.newFont(12))
end

function start_screen.cleanup()
    startOrbs = {}
    startParticles = {}
    startWaves = {}
    startSparkles = {}
end

return start_screen
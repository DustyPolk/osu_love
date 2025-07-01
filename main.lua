-- Advanced Animation Showcase - Modular Version
-- Beautiful particle effects, trails, easing, and interactive animations

-- Load modules
local config = require("game.config")
local state = require("game.state")
local colors = require("utils.colors")
local validation = require("utils.validation")
local collision = require("systems.collision")
local spawner = require("systems.spawner")
local renderer = require("systems.renderer")

-- Entity classes
local Orb = require("entities.orb")
local Particle = require("entities.particle")
local Wave = require("entities.wave")
local Sparkle = require("entities.sparkle")
local HitEffect = require("entities.hit_effect")

-- Game state
local gameState
local orbs = {}
local particles = {}
local waves = {}
local sparkles = {}
local hitEffects = {}

function love.load()
    love.window.setMode(config.window.width, config.window.height)
    love.window.setTitle(config.window.title)
    love.graphics.setBackgroundColor(config.background.color[1], config.background.color[2], config.background.color[3])
    
    love.graphics.setDefaultFilter("linear", "linear")
    
    gameState = state.new()
    
    -- Initialize orbs
    for i = 1, config.orbs.minCount do
        table.insert(orbs, spawner.createRandomOrb(config.window.width, config.window.height))
    end
    
    if config.debug then
        print("DEBUG MODE ENABLED")
        print("Window size: " .. config.window.width .. "x" .. config.window.height)
        print("Initial orbs: " .. #orbs)
    end
    
    print("OSU!-Style Orb Destroyer loaded! Click orbs to destroy them!")
end

function love.update(dt)
    gameState.debugFrame = gameState.debugFrame + 1
    gameState.time = gameState.time + dt
    
    if not validation.isValidNumber(dt) or dt < 0 or dt > 1 then
        if config.debug then
            print("INVALID dt: " .. tostring(dt))
        end
        return
    end
    
    -- Cycle through color palettes
    if gameState.time > 0 and math.floor(gameState.time) % 10 == 0 and math.floor((gameState.time - dt)) % 10 ~= 0 then
        colors.nextPalette()
        if config.debug and gameState.debugFrame % 60 == 0 then
            print("Palette changed to: " .. colors.currentPalette)
        end
    end
    
    -- Update orbs
    for i, orb in ipairs(orbs) do
        if orb then
            orb:update(dt, gameState.time, config.window.width, config.window.height, config.debug)
            spawner.spawnOrbParticles(orb, particles)
        end
    end
    
    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        if not p or not p:update(dt) then
            table.remove(particles, i)
        end
    end
    
    -- Update waves
    for i = #waves, 1, -1 do
        local wave = waves[i]
        if not wave or not wave:update(dt) then
            table.remove(waves, i)
        end
    end
    
    -- Update sparkles
    for i = #sparkles, 1, -1 do
        local s = sparkles[i]
        if not s or not s:update(dt) then
            table.remove(sparkles, i)
        end
    end
    
    -- Update hit effects
    for i = #hitEffects, 1, -1 do
        local effect = hitEffects[i]
        if not effect or not effect:update(dt) then
            table.remove(hitEffects, i)
        end
    end
    
    -- Maintain orb count
    spawner.maintainOrbCount(orbs, config.window.width, config.window.height)
    
    -- Debug info
    if config.debug and gameState.debugFrame % 300 == 0 then
        print(string.format("Frame %d: Orbs=%d, Particles=%d, Waves=%d, Sparkles=%d", 
              gameState.debugFrame, #orbs, #particles, #waves, #sparkles))
    end
end

function love.draw()
    renderer.drawBackground(config.window.width, config.window.height, gameState.time)
    renderer.drawWaves(waves)
    renderer.drawOrbTrails(orbs, config.window.width, config.window.height)
    
    for _, orb in ipairs(orbs) do
        renderer.drawOrb(orb)
    end
    
    renderer.drawParticles(particles)
    renderer.drawSparkles(sparkles)
    renderer.drawHitEffects(hitEffects)
    renderer.drawMouseCursor(gameState.mouseX, gameState.mouseY)
    renderer.drawConnections(orbs)
    renderer.drawUI(config.window.width, config.window.height, gameState, config.debug)
end

function love.mousemoved(x, y)
    if validation.validateCoords(x, y, "mouse moved") then
        gameState.mouseX, gameState.mouseY = x, y
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and validation.validateCoords(x, y, "mouse click") then
        state.recordClick(gameState)
        
        local hit = collision.checkOrbHit(x, y, orbs, gameState, particles, hitEffects)
        if not hit then
            collision.handleMiss(x, y, gameState, hitEffects)
            
            if config.debug then
                print("Miss at " .. x .. ", " .. y)
            end
        end
        
        state.updateAccuracy(gameState)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        colors.nextPalette()
        if config.debug then 
            print("Manual palette change to: " .. colors.currentPalette) 
        end
    elseif key == "d" then
        config.debug = not config.debug
        print("Debug mode: " .. (config.debug and "ON" or "OFF"))
    elseif key == "r" then
        -- Reset game
        state.reset(gameState)
        
        -- Clear all effects
        hitEffects = {}
        particles = {}
        waves = {}
        sparkles = {}
        
        -- Reset orbs
        orbs = {}
        for i = 1, config.orbs.minCount do
            table.insert(orbs, spawner.createRandomOrb(config.window.width, config.window.height))
        end
        
        if config.debug then 
            print("Game reset! New orbs: " .. #orbs) 
        end
        print("Game Reset! Score: 0, Accuracy: 100%")
    end
end
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
local start_screen = require("screens.start_screen")
local pause_menu = require("screens.pause_menu")

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
    
    -- Initialize start screen
    start_screen.init()
    
    if config.debug then
        print("DEBUG MODE ENABLED")
        print("Window size: " .. config.window.width .. "x" .. config.window.height)
        print("Starting in start screen mode")
    end
    
    print("OSU!-Style Orb Destroyer loaded!")
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
    
    -- Handle screen transitions
    if gameState.transition.active then
        gameState.transition.elapsed = gameState.transition.elapsed + dt
        gameState.transition.alpha = gameState.transition.elapsed / gameState.transition.duration
        
        if gameState.transition.elapsed >= gameState.transition.duration then
            gameState.transition.active = false
            gameState.currentScreen = "game"
            gameState.transition.alpha = 0
            
            -- Initialize game orbs when transitioning
            for i = 1, config.orbs.minCount do
                table.insert(orbs, spawner.createRandomOrb(config.window.width, config.window.height))
            end
        end
    end
    
    -- Cycle through color palettes
    if gameState.time > 0 and math.floor(gameState.time) % 10 == 0 and math.floor((gameState.time - dt)) % 10 ~= 0 then
        colors.nextPalette()
        if config.debug and gameState.debugFrame % 60 == 0 then
            print("Palette changed to: " .. colors.currentPalette)
        end
    end
    
    -- Update based on current screen
    if gameState.currentScreen == "start" and not gameState.transition.active then
        start_screen.update(dt, gameState.time, gameState.mouseX, gameState.mouseY)
    elseif gameState.currentScreen == "game" then
    
    -- Skip updates if paused
    if not gameState.paused then
    
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
        
    end -- end of not paused check
    
    -- Update pause menu when paused (should be outside the else block)
    if gameState.paused then
        pause_menu.update(dt, gameState.mouseX, gameState.mouseY)
    end
    
    end -- end of game screen check
end

function love.draw()
    if gameState.currentScreen == "start" and not gameState.transition.active then
        start_screen.draw(gameState.time)
    elseif gameState.currentScreen == "game" then
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
        
        -- Draw pause menu overlay if paused
        if gameState.paused then
            pause_menu.draw()
        end
    end
    
    -- Draw transition overlay
    if gameState.transition.active then
        love.graphics.setColor(0, 0, 0, 1 - gameState.transition.alpha)
        love.graphics.rectangle("fill", 0, 0, config.window.width, config.window.height)
    end
end

function love.mousemoved(x, y)
    if validation.validateCoords(x, y, "mouse moved") then
        gameState.mouseX, gameState.mouseY = x, y
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and validation.validateCoords(x, y, "mouse click") then
        if gameState.currentScreen == "start" and not gameState.transition.active then
            -- Handle start screen mouse click
            local action = start_screen.mousepressed(x, y, button)
            if action == "start_game" then
                -- Start transition to game
                gameState.transition.active = true
                gameState.transition.elapsed = 0
                start_screen.cleanup()
                
                if config.debug then
                    print("Starting transition to game screen")
                end
            end
        elseif gameState.currentScreen == "game" then
            if gameState.paused then
                -- Handle pause menu click
                local action = pause_menu.mousepressed(x, y, button)
                if action == "continue" then
                    gameState.paused = false
                elseif action == "menu" then
                    -- Return to main menu
                    gameState.paused = false
                    gameState.currentScreen = "start"
                    state.reset(gameState)
                    orbs = {}
                    particles = {}
                    waves = {}
                    sparkles = {}
                    hitEffects = {}
                    start_screen.init()
                elseif action == "exit" then
                    love.event.quit()
                end
            else
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
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState.currentScreen == "game" then
            -- Toggle pause
            gameState.paused = not gameState.paused
            if gameState.paused then
                pause_menu.init()
            end
            
            if config.debug then
                print("Game " .. (gameState.paused and "paused" or "unpaused"))
            end
        elseif gameState.currentScreen == "start" then
            -- Quit from start screen
            love.event.quit()
        end
    elseif key == "return" or key == "kpenter" then
        -- Handle Enter key for both start screen and pause menu
        if gameState.currentScreen == "start" and not gameState.transition.active then
            -- Allow Enter key to start game from start screen
            gameState.transition.active = true
            gameState.transition.elapsed = 0
            start_screen.cleanup()
            
            if config.debug then
                print("Starting transition to game screen via Enter key")
            end
        elseif gameState.paused and gameState.currentScreen == "game" then
            -- Handle pause menu Enter key
            local action = pause_menu.keypressed(key)
            if action == "continue" then
                gameState.paused = false
            elseif action == "menu" then
                -- Return to main menu
                gameState.paused = false
                gameState.currentScreen = "start"
                state.reset(gameState)
                orbs = {}
                particles = {}
                waves = {}
                sparkles = {}
                hitEffects = {}
                start_screen.init()
            elseif action == "exit" then
                love.event.quit()
            end
        end
    elseif key == "space" then
        if not gameState.paused then
            colors.nextPalette()
            if config.debug then 
                print("Manual palette change to: " .. colors.currentPalette) 
            end
        end
    elseif key == "d" then
        config.debug = not config.debug
        print("Debug mode: " .. (config.debug and "ON" or "OFF"))
    elseif key == "r" then
        if not gameState.paused then
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
    else
        -- Handle pause menu key input
        if gameState.paused and gameState.currentScreen == "game" then
            local action = pause_menu.keypressed(key)
            if action == "continue" then
                gameState.paused = false
            elseif action == "menu" then
                -- Return to main menu
                gameState.paused = false
                gameState.currentScreen = "start"
                state.reset(gameState)
                orbs = {}
                particles = {}
                waves = {}
                sparkles = {}
                hitEffects = {}
                start_screen.init()
            elseif action == "exit" then
                love.event.quit()
            end
        end
    end
end
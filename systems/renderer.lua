local renderer = {}

local colors = require("utils.colors")
local easing = require("utils.easing")
local validation = require("utils.validation")
local config = require("game.config")

function renderer.drawBackground(width, height, time)
    for y = 0, height, 4 do
        local intensity = math.sin(y * 0.01 + time * 0.5) * 0.02 + 0.02
        love.graphics.setColor(intensity, intensity * 0.5, intensity * 1.5, 0.3)
        love.graphics.rectangle("fill", 0, y, width, 4)
    end
end

function renderer.drawWaves(waves)
    love.graphics.setLineWidth(2)
    for _, wave in ipairs(waves) do
        if wave and validation.validateCoords(wave.centerX, wave.centerY, "wave draw") and 
           validation.isValidNumber(wave.radius) and wave.radius > 0 then
            local color = colors.getColor(wave.color)
            love.graphics.setColor(color[1], color[2], color[3], wave.alpha * 0.5)
            love.graphics.circle("line", wave.centerX, wave.centerY, wave.radius)
        end
    end
end

function renderer.drawOrbTrails(orbs, width, height)
    for _, orb in ipairs(orbs) do
        if not orb or not orb.trail then goto continue_trail end
        
        for i = 1, #orb.trail - 1 do
            local point1 = orb.trail[i]
            local point2 = orb.trail[i + 1]
            
            if point1 and point2 and 
               validation.validateCoords(point1.x, point1.y, "trail point1") and
               validation.validateCoords(point2.x, point2.y, "trail point2") then
                
                local dx = math.abs(point1.x - point2.x)
                local dy = math.abs(point1.y - point2.y)
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance < math.min(width, height) * 0.5 then
                    local alpha = (1 - (i / #orb.trail)) * 0.6
                    local color = colors.getColor(orb.color)
                    love.graphics.setColor(color[1], color[2], color[3], alpha)
                    love.graphics.setLineWidth(orb.size * 0.1 * alpha)
                    love.graphics.line(point1.x, point1.y, point2.x, point2.y)
                end
            end
        end
        
        ::continue_trail::
    end
end

function renderer.drawOrb(orb)
    if not orb or not validation.validateCoords(orb.x, orb.y, "orb draw") then
        return
    end
    
    local pulseSize = orb:getPulseSize()
    local color = colors.getColor(orb.color)
    
    love.graphics.setColor(color[1], color[2], color[3], 0.3)
    love.graphics.circle("fill", orb.x, orb.y, pulseSize * 1.5)
    
    love.graphics.setColor(color[1], color[2], color[3], 0.8)
    love.graphics.circle("fill", orb.x, orb.y, pulseSize)
    
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("fill", orb.x - pulseSize * 0.2, orb.y - pulseSize * 0.2, pulseSize * 0.3)
    
    love.graphics.push()
    love.graphics.translate(orb.x, orb.y)
    love.graphics.rotate(orb.rotation)
    love.graphics.setColor(color[1], color[2], color[3], 0.4)
    for i = 1, 6 do
        love.graphics.push()
        love.graphics.rotate(i * math.pi / 3)
        love.graphics.rectangle("fill", pulseSize * 0.8, -2, pulseSize * 0.3, 4)
        love.graphics.pop()
    end
    love.graphics.pop()
end

function renderer.drawParticles(particles)
    for _, p in ipairs(particles) do
        if p and validation.validateCoords(p.x, p.y, "particle draw") then
            local alpha = p:getAlpha()
            local color = colors.getColor(p.color)
            love.graphics.setColor(color[1], color[2], color[3], alpha * 0.7)
            love.graphics.circle("fill", p.x, p.y, p.size * alpha)
        end
    end
end

function renderer.drawSparkles(sparkles)
    for _, s in ipairs(sparkles) do
        if s and validation.validateCoords(s.x, s.y, "sparkle draw") and 
           validation.isValidNumber(s.life) and s.life > 0 then
            local alpha = easing.outBounce(s.life)
            local color = colors.getColor(s.color)
            love.graphics.setColor(color[1], color[2], color[3], alpha)
            
            love.graphics.push()
            love.graphics.translate(s.x, s.y)
            love.graphics.rotate(s.life * 10)
            for i = 0, 3 do
                love.graphics.push()
                love.graphics.rotate(i * math.pi / 2)
                love.graphics.rectangle("fill", -1, -s.size * alpha, 2, s.size * 2 * alpha)
                love.graphics.pop()
            end
            love.graphics.pop()
        end
    end
end

function renderer.drawHitEffects(hitEffects)
    for _, effect in ipairs(hitEffects) do
        if effect and validation.validateCoords(effect.x, effect.y, "hit effect draw") then
            love.graphics.setColor(1, 1, 1, effect.alpha * 0.8)
            love.graphics.circle("line", effect.x, effect.y, effect.size)
            
            love.graphics.setColor(1, 1, 1, effect.alpha)
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(effect.hitType)
            local textHeight = font:getHeight()
            love.graphics.print(effect.hitType, effect.x - textWidth/2, effect.y - textHeight/2 - 15)
            
            local pointsText = "+" .. effect.points
            local pointsWidth = font:getWidth(pointsText)
            love.graphics.setColor(0.8, 1, 0.2, effect.alpha)
            love.graphics.print(pointsText, effect.x - pointsWidth/2, effect.y - textHeight/2 + 15)
        end
    end
end

function renderer.drawConnections(orbs)
    love.graphics.setLineWidth(1)
    if orbs and #orbs > 1 then
        for i = 1, #orbs do
            for j = i + 1, #orbs do
                local orb1, orb2 = orbs[i], orbs[j]
                
                if orb1 and orb2 and 
                   validation.validateCoords(orb1.x, orb1.y, "connection orb1") and
                   validation.validateCoords(orb2.x, orb2.y, "connection orb2") then
                    
                    local dx = orb1.x - orb2.x
                    local dy = orb1.y - orb2.y
                    local distance = math.sqrt(dx * dx + dy * dy)
                    
                    if validation.isValidNumber(distance) and distance < 200 and distance > 0 then
                        local alpha = (1 - distance / 200) * 0.3
                        local color1 = colors.getColor(orb1.color)
                        local color2 = colors.getColor(orb2.color)
                        love.graphics.setColor(
                            (color1[1] + color2[1]) / 2,
                            (color1[2] + color2[2]) / 2,
                            (color1[3] + color2[3]) / 2,
                            alpha
                        )
                        love.graphics.line(orb1.x, orb1.y, orb2.x, orb2.y)
                    end
                end
            end
        end
    end
end

function renderer.drawMouseCursor(mouseX, mouseY)
    if validation.validateCoords(mouseX, mouseY, "mouse cursor") then
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.circle("line", mouseX, mouseY, 10)
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.circle("fill", mouseX, mouseY, 5)
    end
end

function renderer.drawUI(width, height, gameState, debug)
    love.graphics.setColor(1, 1, 1, 0.9)
    
    love.graphics.print("OSU!-Style Orb Destroyer", 10, 10)
    love.graphics.print("Click on orbs to destroy them!", 10, 30)
    
    local scoreText = "Score: " .. gameState.score
    local scoreWidth = love.graphics.getFont():getWidth(scoreText)
    love.graphics.print(scoreText, width - scoreWidth - 10, 10)
    
    local comboText = "Combo: " .. gameState.combo
    local comboWidth = love.graphics.getFont():getWidth(comboText)
    love.graphics.setColor(1, 0.8, 0.2, 0.9)
    love.graphics.print(comboText, width - comboWidth - 10, 35)
    
    love.graphics.setColor(0.2, 1, 0.8, 0.9)
    local accuracyText = string.format("Accuracy: %.1f%%", gameState.accuracy)
    local accuracyWidth = love.graphics.getFont():getWidth(accuracyText)
    love.graphics.print(accuracyText, width - accuracyWidth - 10, 60)
    
    love.graphics.setColor(0.8, 0.8, 1, 0.9)
    local hitsText = "Hits: " .. gameState.hits .. "/" .. gameState.totalClicks
    local hitsWidth = love.graphics.getFont():getWidth(hitsText)
    love.graphics.print(hitsText, width - hitsWidth - 10, 85)
    
    local maxComboText = "Max Combo: " .. gameState.maxCombo
    local maxComboWidth = love.graphics.getFont():getWidth(maxComboText)
    love.graphics.print(maxComboText, width - maxComboWidth - 10, 110)
    
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("Controls:", 10, height - 120)
    love.graphics.print("• Click orbs to destroy them", 10, height - 100)
    love.graphics.print("• SPACE: Change palette", 10, height - 80)
    love.graphics.print("• R: Reset game", 10, height - 60)
    love.graphics.print("• D: Toggle debug", 10, height - 40)
    
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.print("FPS: " .. love.timer.getFPS(), width - 80, height - 40)
    
    if debug then
        love.graphics.setColor(1, 0.5, 0.5, 0.8)
        love.graphics.print("DEBUG MODE ON", width - 150, height - 20)
    end
end

return renderer
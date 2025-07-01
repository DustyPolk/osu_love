local state = {}

function state.new()
    return {
        score = 0,
        hits = 0,
        misses = 0,
        combo = 0,
        maxCombo = 0,
        totalClicks = 0,
        accuracy = 100.0,
        time = 0,
        debugFrame = 0,
        mouseX = 0,
        mouseY = 0,
        paused = false,
        pauseMenuSelection = 1,
        currentScreen = "start",
        transition = {
            active = false,
            alpha = 0,
            duration = 1.0,
            elapsed = 0
        }
    }
end

function state.updateAccuracy(gameState)
    if gameState.totalClicks > 0 then
        gameState.accuracy = (gameState.hits / gameState.totalClicks) * 100
    else
        gameState.accuracy = 100.0
    end
end

function state.addScore(gameState, basePoints, hitType)
    local comboMultiplier = 1 + (gameState.combo * 0.1)
    local finalPoints = math.floor(basePoints * comboMultiplier)
    gameState.score = gameState.score + finalPoints
    return finalPoints
end

function state.recordHit(gameState)
    gameState.hits = gameState.hits + 1
    gameState.combo = gameState.combo + 1
    gameState.maxCombo = math.max(gameState.maxCombo, gameState.combo)
end

function state.recordMiss(gameState)
    gameState.misses = gameState.misses + 1
    gameState.combo = 0
end

function state.recordClick(gameState)
    gameState.totalClicks = gameState.totalClicks + 1
end

function state.reset(gameState)
    gameState.score = 0
    gameState.hits = 0
    gameState.misses = 0
    gameState.combo = 0
    gameState.maxCombo = 0
    gameState.totalClicks = 0
    gameState.accuracy = 100.0
end

return state
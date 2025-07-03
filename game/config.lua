local config = {}

config.window = {
    width = 1200,
    height = 800,
    title = "OSU!-Style Orb Destroyer"
}

config.background = {
    color = {0.02, 0.02, 0.08}
}

config.orbs = {
    minSize = 15,
    maxSize = 35,
    pulseSpeed = 3,
    trailLength = 20,
    -- OSU!-style timing parameters
    spawnTime = 1.0,        -- How long before orb becomes clickable
    hitWindow = 0.5,        -- How long orb stays clickable
    fadeInTime = 0.8,       -- Fade in animation duration
    fadeOutTime = 0.3       -- Fade out animation duration
}

config.patterns = {
    groupSize = {min = 2, max = 4},     -- Number of orbs per group
    spawnInterval = 2.5,                -- Time between pattern groups
    orbSpacing = 0.3,                   -- Time between orbs in a group
    difficultyScale = 1.0               -- Multiplier for spawn rates
}

config.scoring = {
    perfect = 100,
    good = 75,
    okay = 50,
    miss = 0,
    comboMultiplier = 0.1
}

config.hitAccuracy = {
    perfect = 0.8,
    good = 0.6
}

config.particles = {
    explosionCount = 8,
    minSpeed = 100,
    maxSpeed = 150,
    minLife = 0.8,
    maxLife = 1.2,
    minSize = 3,
    maxSize = 5,
    gravity = {25, 75}
}

config.debug = false

return config
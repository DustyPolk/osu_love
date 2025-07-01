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
    minCount = 8,
    minSize = 15,
    maxSize = 35,
    pulseSpeed = 3,
    trailLength = 20
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
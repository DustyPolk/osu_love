local colors = {}

colors.palettes = {
    {
        {0.2, 0.1, 0.4},  -- Deep purple
        {0.4, 0.2, 0.6},  -- Purple
        {0.6, 0.4, 0.8},  -- Light purple
        {0.8, 0.6, 1.0},  -- Very light purple
        {1.0, 0.8, 0.9}   -- Pink
    },
    {
        {0.1, 0.2, 0.4},  -- Deep blue
        {0.2, 0.4, 0.6},  -- Blue
        {0.4, 0.6, 0.8},  -- Light blue
        {0.6, 0.8, 1.0},  -- Very light blue
        {0.8, 1.0, 1.0}   -- Cyan
    },
    {
        {0.4, 0.1, 0.2},  -- Deep red
        {0.6, 0.2, 0.3},  -- Red
        {0.8, 0.4, 0.5},  -- Light red
        {1.0, 0.6, 0.7},  -- Pink
        {1.0, 0.8, 0.8}   -- Light pink
    }
}

colors.currentPalette = 1

function colors.getColor(colorIndex)
    local palette = colors.palettes[colors.currentPalette]
    local safeIndex = ((colorIndex - 1) % #palette) + 1
    return palette[safeIndex]
end

function colors.nextPalette()
    colors.currentPalette = (colors.currentPalette % #colors.palettes) + 1
end

function colors.setPalette(index)
    colors.currentPalette = ((index - 1) % #colors.palettes) + 1
end

return colors
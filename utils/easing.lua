local easing = {}
local validation = require("utils.validation")

function easing.inOutQuad(t)
    if not validation.isValidNumber(t) then
        return 0
    end
    t = math.max(0, math.min(1, t))
    if t < 0.5 then
        return 2 * t * t
    else
        return -1 + (4 - 2 * t) * t
    end
end

function easing.inOutCubic(t)
    if not validation.isValidNumber(t) then
        return 0
    end
    t = math.max(0, math.min(1, t))
    if t < 0.5 then
        return 4 * t * t * t
    else
        local f = 2 * t - 2
        return 1 + f * f * f / 2
    end
end

function easing.outBounce(t)
    if not validation.isValidNumber(t) then
        return 0
    end
    t = math.max(0, math.min(1, t))
    if t < 1/2.75 then
        return 7.5625 * t * t
    elseif t < 2/2.75 then
        t = t - 1.5/2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5/2.75 then
        t = t - 2.25/2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625/2.75
        return 7.5625 * t * t + 0.984375
    end
end

return easing
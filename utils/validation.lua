local validation = {}

function validation.isValidNumber(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

function validation.validateCoords(x, y, source, debug)
    if not validation.isValidNumber(x) or not validation.isValidNumber(y) then
        if debug then
            print(string.format("INVALID COORDS in %s: x=%s, y=%s", source, tostring(x), tostring(y)))
        end
        return false
    end
    if math.abs(x) > 10000 or math.abs(y) > 10000 then
        if debug then
            print(string.format("EXTREME COORDS in %s: x=%.2f, y=%.2f", source, x, y))
        end
        return false
    end
    return true
end

return validation
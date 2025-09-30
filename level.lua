local levels = {
    { bloons={1,1,1}, rate=5, timer=0, nextBloon=1 }
}

---@type Bloon[]
local bloons = {
    Bloon, SuperBloon
}

local level = levels[1]
level.current = 1

local function createBloon(i)
    local b = bloons[i]:new()
    -- avoid overlapping bloons
    local tries = 0
    local maxTries = 10
    local minDistance = 100
    while math.abs(b.x - states.lastSpawnCoord) < minDistance and tries < maxTries do
        b.x = love.math.random(50, W - 50)
        tries = tries + 1
    end
    return b
end

function level.update(dt)
    if level.current > #levels then -- loop
        level.current = 1
    end

    level.spawn(dt)
end

function level.spawn(dt)
    local l = level
    if l.nextBloon > #l.bloons then
        level.current = level.current + 1
    end

    if l.timer <= 0 then
        local bloon = createBloon(l.bloons[l.nextBloon])
        l.nextBloon = l.nextBloon + 1

        states.lastSpawnCoord = bloon.x
        l.timer = l.rate

        table.insert(states.bloons, bloon)
    end
    l.timer = l.timer - dt
end

function level.draw()
    for _, b in pairs(states.bloons) do
        b:draw()
    end
end

return level


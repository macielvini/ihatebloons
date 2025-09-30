---@class Bloon
Bloon = {
    x = 0,
    y = 0,
    dy = 0,
    size = 0,
    isDead = true
}

Bloon.__index = Bloon

function Bloon:new()
    local o = {
        x = love.math.random(50, W-50),
        y = H + 10,
        dy = 50,
        size = 50,
        isDead = false
    }
    setmetatable(o, self)
    return o
end

function Bloon:update(dt)
    self.y = self.y - self.dy * dt

    if self.y + self.size <= 0 then
        self.isDead = true
    end
end

function Bloon:draw()
    local scale = self.size * 2 / assets.bloons[1]:getWidth()
    love.graphics.draw(assets.bloons[1], self.x-self.size, self.y-self.size, 0, scale, scale)
    
    if DEBUG then
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.x, self.y, self.size, self.size)
    end
end

function Bloon:hit(i)
    self.isDead = true
    love.audio.play(sounds.pop)
    table.remove(states.bloons, i)
end

function Bloon:checkMouseCollision()
    return self.x - self.size <= love.mouse.getX()
        and self.x + self.size >= love.mouse.getX()
        and self.y - self.size <= love.mouse.getY()
        and self.y + self.size >= love.mouse.getY()
end

SuperBloon = Bloon:new()
SuperBloon.__index = SuperBloon

function SuperBloon:new()
    self.dy = 100
    setmetatable(o, self)
    return o
end


function spawnBloons(dt)
    if states.timeForNextSpawn <= 0 then
        local b = Bloon:new()
        -- avoid overlapping bloons
        local tries = 0
        local maxTries = 10
        local minDistance = 100
        while math.abs(b.x - states.lastSpawnCoord) < minDistance and tries < maxTries do
            b.x = love.math.random(50, W - 50)
            tries = tries + 1
        end

        table.insert(states.bloons, b)
        states.lastSpawnCoord = b.x
        states.timeForNextSpawn = states.timeBetweenSpawn
    end

    states.timeForNextSpawn = states.timeForNextSpawn - dt
end

function drawBloons()
    for _, b in pairs(states.bloons) do
        b:draw()
    end
end
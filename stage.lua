---@type Bloon[]
local bloonTypes = {
    Bloon, SuperBloon
}

local function createBloon(i)
    local b = bloonTypes[i]:new()
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

---@class Stage
local Stage = {
    bloons={}, rate=1, timer=0, nextBloon=1, backgrounds={}, next=1
}
Stage.__index = Stage

---@param bloons number[] bloon types 
---@param rate number spawn rate
---@param bgs number[] bg indexes from assets.bg
function Stage:new(bloons, rate, bgs)
    local o = {
        bloons=bloons, rate=rate, timer=0, nextBloon=1, next=1, backgrounds=bgs or {1,2,3,4}
    }
    setmetatable(o, self)
    return o
end

function Stage:draw()
    --draw background
    love.graphics.setBackgroundColor(0.133, 0.616, 0.949)

    local start = self.backgrounds[1]
    local end_ = self.backgrounds[#self.backgrounds]
    for i=start, end_ do
        local bg = assets.bg[i]
        local scaleX = love.graphics.getWidth() / bg:getWidth()
        local scaleY = love.graphics.getHeight() / bg:getHeight()
        local x, y = 0, H-bg:getHeight()*scaleY
        love.graphics.draw(bg, x, y, 0, scaleX, scaleY)
    end

    -- draw bloons
    for _, b in pairs(states.bloons) do
        b:draw()
    end

end

function Stage:update(dt)
    if self.next == 0 then return end -- game ends
    
    if self.nextBloon > #self.bloons then
        -- go to next level
    end

    if self.nextBloon <= #self.bloons then
        self:spawn(dt)
    end
end

function Stage:spawn(dt)
    if self.timer <= 0 then
        local bloon = createBloon(self.bloons[self.nextBloon])
        table.insert(states.bloons, bloon)
        
        -- update states
        states.lastSpawnCoord = bloon.x
        self.timer = self.rate
        self.nextBloon = self.nextBloon + 1
    end
    self.timer = self.timer - dt
end

local baseBg = { 1, 2, 3, 4}
local stages = {
    Stage:new({1, 1, 1}, 3, baseBg),
    Stage:new({2, 1, 2}, 3, baseBg),
}

return stages


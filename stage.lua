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
    bloons={}, rate=1, timer=0, nextBloon=0, backgrounds={}, startDelay=0

}
Stage.__index = Stage

---@param bloons number[] bloon types 
---@param rate number spawn rate
---@param bgs? number[] bg indexes from assets.bg
function Stage:new(bloons, rate, bgs, delay)
    local o = {
        bloons=bloons, rate=rate, timer=0, nextBloon=0, backgrounds=bgs or {1,2,3,4}, startDelay=delay or 3
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

    -- draw stage timer
    if not self:started() then
        local f = love.graphics.getFont()
        local nf = love.graphics.newFont(32)
        love.graphics.setFont(nf)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Next stage starts in " .. math.ceil(self.startDelay), 0, H/2, W, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(f)
    end
end

function Stage:update(dt)
    if self.nextBloon == 0 then
        self:start(dt)
        return
    end
    
    if self:isOver() then
        return
    end

    self:spawn(dt)
end

function Stage:spawn(dt)
    if self.timer <= 0 and self.nextBloon > 0 and self.nextBloon <= #self.bloons then
        local bloon = createBloon(self.bloons[self.nextBloon])
        bloon.dy = bloon.dy + (math.floor(states.timer) * 2)
        table.insert(states.bloons, bloon)
        
        -- update states
        states.lastSpawnCoord = bloon.x
        self.timer = self.rate
        self.nextBloon = self.nextBloon + 1
    end
    self.timer = self.timer - dt
end

function Stage:isOver()
    return self.nextBloon > #self.bloons
end

function Stage:start(dt)
    if not self:started() then
        self.startDelay = self.startDelay - dt
        return
    end
    self.nextBloon = 1
end

function Stage:started()
    return self.startDelay <= 0
end

return Stage


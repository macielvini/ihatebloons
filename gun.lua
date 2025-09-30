---@class Gun
Gun = {
    isFiring=false,
    fireRate=1, -- time between shots
    timeForNextShot=0, -- time remaining until next shot
}

function Gun:update(dt)
    self:reload(dt)
end

-- reload gun according to fire rate
function Gun:reload(dt)
     local reloadLength = sounds.reload:getDuration("seconds")

    if self.timeForNextShot <= reloadLength and not self:canFire() then
        love.audio.play(sounds.reload)
    end

    if not self:canFire() then
        self.timeForNextShot = self.timeForNextShot - dt
        self.isFiring = false
    end
end

function Gun:draw()
    local scale = 1
    local mx, my = love.mouse.getPosition()
    local img = assets.gun
    local iw, ih = img:getWidth()*scale, img:getHeight()*scale
    local maxY = H - ih
    local y = my + ih/2
    local x = mx + iw/2

    if x > W-50 then -- prevent gun from going offscreen
        x = W-50
    end
    if y > H-50 then -- prevent gun from going offscreen
        y = H-50
    end

    if y < maxY then
        y = maxY
    end

    love.graphics.draw(img, x, y, 0, scale, scale)
end

function Gun:canFire()
    return self.timeForNextShot <= 0
end

function Gun:fire()
    self.isFiring = true
    self.timeForNextShot = self.fireRate
    love.audio.play(sounds.fire)
end


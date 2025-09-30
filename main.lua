W, H = 800, 600
DEBUG = true

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.audio.setVolume(0.5)

    require "gun"
    require "bloon"

    assets = {
        cursor = love.image.newImageData("assets/aim.png"),
        bloons = {love.graphics.newImage("assets/bloon.png")},
        gun = love.graphics.newImage("assets/gun.png"),
        bg = {
            love.graphics.newImage("assets/bg/1.png"),
            love.graphics.newImage("assets/bg/2.png"),
            love.graphics.newImage("assets/bg/3.png"),
            love.graphics.newImage("assets/bg/4.png")
        }
    }

    sounds = {
        fire = love.audio.newSource("sfx/gun_fire.wav", "static"),
        reload = love.audio.newSource("sfx/gun_reload.wav", "static"),
        pop = love.audio.newSource("sfx/bloon_pop.wav", "static")
    }

    states = {
        timeBetweenSpawn=1,
        timeForNextSpawn=0,
        lastSpawnCoord=0,
        score=0
    }
    
    ---@type Bloon[]
    states.bloons = {} 
    
    local cursor = love.mouse.newCursor(assets.cursor, assets.cursor:getWidth()/2, assets.cursor:getHeight()/2)
    love.mouse.setCursor(cursor)


end

function love.update(dt)
    spawnBloons(dt)
    for i=#states.bloons, 1, -1 do
        local b = states.bloons[i]
        b:update(dt)
        if Gun.isFiring and b:checkMouseCollision() then
            b:hit(i)
            states.score = states.score + 1
        end
    end

    Gun:update(dt)
end

function love.draw()
    drawBg()

    drawBloons()
    Gun:draw()

    local font = love.graphics.newFont(18)
    love.graphics.setFont(font)
    love.graphics.print("Bloons popped " .. states.score, 10, 10)
end

function love.mousepressed(x, y, button, isTouch, presses)
    if button == 1 then
        if Gun:canFire() then
            Gun.isTriggerPulled = true
            Gun:fire()
        end 
    end
end

function love.mousereleased(x, y, button, isTouch, presses)
    if button == 1 then
        Gun.isTriggerPulled = false
    end
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
end

function drawBg()
    love.graphics.setBackgroundColor(0.133, 0.616, 0.949)
    for i=1, #assets.bg do
        local bg = assets.bg[i]
        local scaleX = love.graphics.getWidth() / bg:getWidth()
        local scaleY = love.graphics.getHeight() / bg:getHeight()
        local x, y = 0, H-bg:getHeight()*scaleY
        love.graphics.draw(bg, x, y, 0, scaleX, scaleY)
    end
end
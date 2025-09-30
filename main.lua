W, H = 800, 600
DEBUG = true

if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.audio.setVolume(0.5)

    require "gun"
    require "bloon"
    local stages = require "stage"

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
        score=0,
        stage=1
    }

    ---@return Stage
    function getCurrentStage()
        return stages[states.stage]
    end

    ---@type Bloon[]
    states.bloons = {} 
    
    local cursor = love.mouse.newCursor(assets.cursor, assets.cursor:getWidth()/2, assets.cursor:getHeight()/2)
    love.mouse.setCursor(cursor)
end

function love.update(dt)
    local stage = getCurrentStage()
    stage:update(dt)
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

local function hud()
    local currFont = love.graphics.getFont()
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    love.graphics.print("Score " .. states.score, 10, 10)
    love.graphics.print("Level  " .. 1, 10, 30)
    love.graphics.setFont(currFont)
end

function love.draw()
    local stage = getCurrentStage()
    stage:draw()
    Gun:draw()
    hud()
end

function love.mousepressed(x, y, button, isTouch, presses)
    if button == 1 then
        if Gun:canFire() then
            Gun:fire()
        end 
    end
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
end
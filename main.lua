W, H = 800, 600
DEBUG = false

if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

local function generateStages ()
    local total = love.math.random(1, 10)
    local stages = {}
    for i=1, total do
        local totalBloons = love.math.random(1,10)
        local bloonTypes = {}
        for j=1, totalBloons do
            table.insert(bloonTypes, love.math.random(1, 2))
        end
        stages[i] = Stage:new(bloonTypes, love.math.random(1, 5))
    end
    return stages
end

local function startGame()
    states = {
        gameIsOver=false,
        timeBetweenSpawn=1,
        timeForNextSpawn=0,
        lastSpawnCoord=0,
        score=0,
        stage=1,
        stages = generateStages(),
        timer = 0
    }
    ---@type Bloon[]
    states.bloons = {}
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.audio.setVolume(0.5)

    require "gun"
    require "bloon"
    Stage = require "stage"

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

    states = {}
    startGame()

    ---@return Stage | nil
    function getCurrentStage()
        return states.stages[states.stage]
    end
    
    local cursor = love.mouse.newCursor(assets.cursor, assets.cursor:getWidth()/2, assets.cursor:getHeight()/2)
    love.mouse.setCursor(cursor)
end

function love.update(dt)
    -- bloons must be updated on before everything
    for i=#states.bloons, 1, -1 do
        local b = states.bloons[i]
        b:update(dt, i)
        if Gun.isFiring and b:checkMouseCollision() then
            b:hit(i)
            states.score = states.score + 1
        end

        if b.y + b.size < 0 then
            states.gameIsOver = true
            return
        end
    end

    if states.gameIsOver then return end

    -- gun must be updated after bloons
    Gun:update(dt) 

    local stage = getCurrentStage()

    if not stage then
        states.gameIsOver = true
        return
    end

    stage:update(dt)

    if stage:isOver() and #states.bloons == 0 then
        states.stage = states.stage + 1
        return
    end

    states.timer = states.timer + dt -- global timer
end

local function drawHud()
    local currFont = love.graphics.getFont()
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    love.graphics.print("Score " .. states.score, 10, 10)
    love.graphics.print("Level  " .. states.stage .. " / " .. #states.stages, 10, 30)
    love.graphics.setFont(currFont)
end

function love.draw()
    if states.gameIsOver then
        local f = love.graphics.getFont()
        local nf = love.graphics.newFont(32)
        love.graphics.setFont(nf)
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("Game Over", 0, H/2, W, "center")
        love.graphics.setFont(f)
        love.graphics.printf("Press 'r' to restart", 0, H/2 + 50, W, "center")
        love.graphics.setColor(1, 1, 1)
        return
    end

    local stage = getCurrentStage()
    if stage then
        stage:draw()
        Gun:draw()
        drawHud()
    end
end

function love.mousepressed(x, y, button, isTouch, presses)
    if states.gameIsOver then return end
    
    if button == 1 then
        if Gun:canFire() then
            Gun:fire()
        end 
    end
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end

    if key == 'r' and states.gameIsOver then
        startGame()
    end
end
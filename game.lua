-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

print("Processing game.lua")

local composer = require("composer")
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

local gg = require("common")

local ui = require("ui")

local onKeyEvent = require("keys")

local landscape = require("landscape")

--require "class.class"

local landingSpeeds = {
    PERFECT_LANDING = 30,
    GOOD_LANDING = 100,
    OK_LANDING = 200
}

local landingRotations = {
    PERFECT_LANDING = 5,
    GOOD_LANDING = 10,
    OK_LANDING = 20    
}


--------------------------------------------
local WallCollisionFilter = {groupIndex = -2}

local uiGroup = display.newGroup() -- Display group for UI objects like the score

local livesText
local scoreText
local lives = 3
local score = 0
local died = false

math.randomseed(os.time())

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth,
                                display.actualContentHeight,
                                display.contentCenterX

print("Set a few variables")

local function rotateVertices(v, angle)
    angle = math.rad(angle)
    local centerX = 0
    local centerY = 0
    local c = table.getn(v)
    local nv = table.copy(v)
    local i
    for i = 1, c, 2 do
        local x = v[i]
        local y = v[i + 1]
        local newX = centerX + (x - centerX) * math.cos(angle) - (y - centerY) *
                         math.sin(angle);
        local newY = centerY + (x - centerX) * math.sin(angle) + (y - centerY) *
                         math.cos(angle);
        nv[i] = newX
        nv[i + 1] = newY
    end

    rotateVertices = nv
end

local function createParticles(x, y)
    local c = math.random(8, 10)
    local i
    for i = 1, c do
        local p =
            display.newRect(x, y, math.random(10, 40), math.random(10, 40))
        physics.addBody(p, {density = 1.0, friction = 0.3})
        p.rotation = math.random(-180, 180)
        p:setLinearVelocity(math.random(-600, 600), math.random(-600, 600))

        transition.to(p, {
            alpha = 0.0,
            time = 1000,
            onComplete = function() display.remove(p) end
        })
    end
end

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
    rotationText.text = "Rot: " .. string.format("%2d", triangle.rotation)
    speedText.text = "Speed: " .. string.format("%2d", vectorLength(triangle:getLinearVelocity()))
end

function applyAngularForceLeft() triangle:applyAngularImpulse(-70 * 3) end

function applyAngularForceRight() triangle:applyAngularImpulse(70 * 3) end

function applyForce(obj)
    local q = 10 * 1.3
    local angle = math.rad(triangle.rotation - 90)
    local xComp = math.cos(angle)
    local yComp = math.sin(angle)
    triangle:applyLinearImpulse(xComp * q, yComp * q, triangle.x, triangle.y)
end

function createBoundaries()
    print("Caalling create boundaries")

    local leftWall = display.newRect(gg.screenLeft - 25, gg.centerY, 50,
                                     gg.screenHeight)
    physics.addBody(leftWall, "static", {
        density = 0,
        friction = 0.3,
        bounce = .2,
        filter = WallCollisionFilter
    })
    local rightWall = display.newRect(gg.screenWidth + 26, gg.centerY, 50,
                                      gg.screenHeight)
    physics.addBody(rightWall, "static", {
        density = 0,
        friction = 0.3,
        bounce = .2,
        filter = WallCollisionFilter
    })

    local topWall = display.newRect(gg.centerX, gg.screenTop - 26,
                                    gg.screenWidth, 50)
    physics.addBody(topWall, "static", {
        density = 0,
        friction = 0.3,
        bounce = .2,
        filter = WallCollisionFilter
    })
    local bottomWall = display.newRect(gg.centerX, gg.screenBottom + 25,
                                       gg.screenWidth, 50)
    physics.addBody(bottomWall, "static", {
        density = 0,
        friction = 0.3,
        bounce = .2,
        filter = WallCollisionFilter
    })
end

local function resetShip()
    triangle.isBodyActive = false
    triangle.x = display.contentCenterX
    triangle.y = 100
    triangle.rotation = 0
    triangle.angularVelocity = 0
    triangle:setLinearVelocity(0, 0)

    -- Fade in the ship
    transition.to(triangle, {
        alpha = 1,
        time = 500,
        onComplete = function()
            triangle.isBodyActive = true
            died = false
        end
    })    
end

local function landRestoreShip()
    local text
    local speed = triangle:getLinearVelocity()
    if speed < landingSpeeds.PERFECT_LANDING then
        text = "Perfect landing"
        score = score + 100
    elseif speed < landingSpeeds.GOOD_LANDING then
        text = "Great landing"
        score = score + 40
    else
        text = "Decent landing"
        score = score + 10
    end
    text = text.." "..speed

    triangle.rotation = 0
    triangle.angularVelocity = 0
    triangle:setLinearVelocity(0, 0)

    local successText = display.newText(uiGroup, text, display.contentCenterX, display.contentCenterY,
                                native.systemFont, 36)
    successText.alpha = 0


    -- Fade in the ship
    transition.to(successText, {
        alpha = 1,
        time = 500,
        onComplete = function()
            transition.to(successText, {
                alpha = 0,
                time = 500,
                onComplete = function()
                    resetShip()
                    landscape.createLandscape()
                end
            })
        end
    })  
end

local function dieRestoreShip()
    createParticles(triangle.x, triangle.y)

    resetShip()
end

function vectorLength( ... ) -- ( objA ) or ( x1, y1 )
    local len
    if( type(arg[1]) == "number" ) then
        len = math.sqrt(arg[1] * arg[1] + arg[2] * arg[2])
    else
        len = math.sqrt(arg[1].x * arg[1].x + arg[1].y * arg[1].y)
    end
    return len
end

local function onPlayerColliderGround(self, event)

    if (died == false) then
        if (event.phase == "began") then

            local tooMuch = false
            -- if

            if event.other.name == "landing" then

                if (triangle.rotation < -landingRotations.OK_LANDING or triangle.rotation > landingRotations.OK_LANDING) then
                    tooMuch = true
                elseif vectorLength(triangle:getLinearVelocity()) > landingSpeeds.OK_LANDING then
                    tooMuch = true
                else
                    died = true
                    timer.performWithDelay(0, landRestoreShip)
                end
            end

            if event.other.name == "ground" or tooMuch then
                died = true

                -- Update lives
                -- lives = lives - 1
                -- livesText.text = "Lives: " .. lives

                if (lives == 0) then
                    --  display.remove( triangle )
                else
                    -- triangle.alpha = 0

                    timer.performWithDelay(0, dieRestoreShip)
                end
            end
        elseif (event.phase == "ended") then
        end
    end
end

function scene:create(event)

    print("Calling scene:create")

    livesText = display.newText(uiGroup, "Lives: " .. lives, 200, 80,
                                native.systemFont, 36)
    scoreText = display.newText(uiGroup, "Score: " .. score, 400, 80,
                                native.systemFont, 36)
    rotationText = display.newText(uiGroup, "Rot: 0", 600, 80,
                                   native.systemFont, 36)
    speedText = display.newText(uiGroup, "Speed: 0", 780, 80,
                                   native.systemFont, 36)

    Runtime:addEventListener("enterFrame", updateText)

    -- Called when the scene's view does not exist.
    --
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

    local sceneGroup = self.view

    -- We need physics started to add bodies, but we don't want the simulaton
    -- running until the scene is on the screen.
    physics.start()
    physics.pause()

    createBoundaries()

    -- physics.setDrawMode("hybrid")

    -- create a grey rectangle as the backdrop
    -- the physical screen will likely be a different shape than our defined content area
    -- since we are going to position the background from it's top, left corner, draw the
    -- background at the real top, left corner.
    local background = display.newRect(display.screenOriginX,
                                       display.screenOriginY, screenW, screenH)
    background.anchorX = 0
    background.anchorY = 0
    background:setFillColor(.5)

    local triangleShape = {0, -40, 37, 40, -37, 40}

    rotateVertices(triangleShape, 0)

    triangle = display.newPolygon(halfW, 0, triangleShape);
    triangle.x = 200
    triangle.y = 300
    triangle.rotation = 0
    -- define the shape table (once created, this can be used multiple times)
    physics.addBody(triangle, {
        shape = triangleShape,
        density = 3.0,
        friction = 0.3,
        bounce = 0.2
    })
    triangle.linearDamping = 1.0
    triangle.angularDamping = 4.0

    triangle.collision = onPlayerColliderGround
    triangle:addEventListener("collision")
    triangle.name = "player"

    landscape.createLandscape()

    ui.loadGraphics()

    -- all display objects must be inserted into group
    sceneGroup:insert(background)
end

function scene:show(event)
    print("calling scene:show")

    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        -- Called when the scene is now on screen
        --
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc.
        physics.start()
        physics.setGravity(0, 9.8)

        Runtime:addEventListener("key", onKeyEvent)
    end
end

function scene:hide(event)
    print("calling scene:hide")

    local sceneGroup = self.view

    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
        physics.stop()
    elseif phase == "did" then
        -- Called when the scene is now off screen
    end

end

function scene:destroy(event)
    print("calling scene:destroy")

    -- Called prior to the removal of scene's "view" (sceneGroup)
    --
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc.
    local sceneGroup = self.view

    package.loaded[physics] = nil
    physics = nil
end

---------------------------------------------------------------------------------

print("Adding listeners")
-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------




print("returning scene")

return scene

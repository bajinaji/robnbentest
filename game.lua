-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------
local composer = require("composer")
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

local gg = require("common")

--require "class.class"

local ui = {

    interaction = false,
    buttonImage = "images/ui/dirUP.png",
    leftButtonImage = "images/ui/dirLEFT.png",
    rightButtonImage = "images/ui/dirRIGHT.png",
    boostButton = nil,
    leftButton = nil,
    rightButton = nil
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
    rotationText.text = "Rotation: " .. string.format("%2d", triangle.rotation)
end

-- Called when a key event has been received
local function onKeyEvent(event)

    -- Print which key was pressed down/up
    -- local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase

    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if (event.keyName == "back") then
        if (system.getInfo("platform") == "android") then return true end
    end

    if (event.keyName == "left") then
        if event.phase == "up" then
            Runtime:removeEventListener("enterFrame", applyAngularForceLeft)
        elseif event.phase == "down" then
            Runtime:addEventListener("enterFrame", applyAngularForceLeft)
        end
    elseif (event.keyName == "right") then
        if event.phase == "up" then
            Runtime:removeEventListener("enterFrame", applyAngularForceRight)
        elseif event.phase == "down" then
            Runtime:addEventListener("enterFrame", applyAngularForceRight)
        end
    elseif (event.keyName == "down") then
        if event.phase == "up" then
            Runtime:removeEventListener("enterFrame", applyForce)
        elseif event.phase == "down" then
            Runtime:addEventListener("enterFrame", applyForce)
        end
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
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

local function restoreShip()
    createParticles(triangle.x, triangle.y)

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

local function onPlayerColliderGround(self, event)

    if (died == false) then
        if (event.phase == "began") then

            local tooMuch = false
            -- if

            if event.other.name == "landing" and
                (triangle.rotation >= -10 and triangle.rotation <= 10) and
                tooMuch == false then
                score = score + 10
                updateText()

                died = true
                timer.performWithDelay(0, restoreShip)
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

                    timer.performWithDelay(0, restoreShip)
                end
            end
        elseif (event.phase == "ended") then
        end
    end
end

function scene:create(event)

    livesText = display.newText(uiGroup, "Lives: " .. lives, 200, 80,
                                native.systemFont, 36)
    scoreText = display.newText(uiGroup, "Score: " .. score, 400, 80,
                                native.systemFont, 36)
    rotationText = display.newText(uiGroup, "Rotation: 0", 600, 80,
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

    createLandscape()

    ui.loadGraphics()

    -- all display objects must be inserted into group
    sceneGroup:insert(background)
end

function createLandscape()
    -- Create landing pad
    local landingPadWidth = 200
    local lx = math.random(0, gg.screenWidth - landingPadWidth)
    local ly = display.viewableContentHeight - 400 + math.random(-200, 200)
    local line = display.newLine(lx, ly, lx + landingPadWidth, ly)
    line.name = "landing"
    line:setStrokeColor(0, 1, 0, 1)
    line.strokeWidth = 8
    physics.addBody(line, "static", {
        density = 1.0,
        friction = 0.1,
        bounce = .2,
        filter = WallCollisionFilter
    })

    -- Create landscape around landing pad
    -- Create to left
    local x = lx + landingPadWidth
    y = ly
    while (x < screenW) do x, y = appendLineWithinScreen(x, y, 1) end

    -- Create to right
    x = lx
    y = ly
    while (x > 0) do x, y = appendLineWithinScreen(x, y, -1) end
end

function appendLineWithinScreen(x, y, direction)
    local x2
    if direction == 1 then
        x2 = x + math.random(20, 100)
    else
        x2 = x + math.random(-100, -20)
    end

    if direction == 1 and x2 > gg.screenWidth then
        x2 = gg.screenWidth
    elseif direction == -1 and x2 < 0 then
        x2 = 0
    end

    local y2 = y + math.random(-100, 100)
    if y2 > display.viewableContentHeight - 80 then
        y2 = display.viewableContentHeight - 80
    elseif y2 < 0 then
        y2 = 0
    end
    local line = display.newLine(x, y, x2, y2)
    line:setStrokeColor(1, 1, 1, 1)
    line.strokeWidth = 8
    line.name = "ground"
    physics.addBody(line, "static", {
        density = 0,
        friction = 0.3,
        bounce = .2,
        filter = WallCollisionFilter
    })
    return x2, y2
end

function scene:show(event)
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

    -- Called prior to the removal of scene's "view" (sceneGroup)
    --
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc.
    local sceneGroup = self.view

    package.loaded[physics] = nil
    physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

local function onLeftButtonTouch(self, event)
    if (event.phase == "began") then
        Runtime:addEventListener("enterFrame", applyAngularForceLeft)
        --print("Touch event began on: " .. self)

    elseif (event.phase == "ended") then
        Runtime:removeEventListener("enterFrame", applyAngularForceLeft)
        --print("Touch event ended on: " .. self)
    end
    return true
end

local function onRightButtonTouch(self, event)
    if (event.phase == "began") then
        Runtime:addEventListener("enterFrame", applyAngularForceRight)
        --print("Touch event began on: " .. self)

    elseif (event.phase == "ended") then
        Runtime:removeEventListener("enterFrame", applyAngularForceRight)
        --print("Touch event ended on: " .. self)
    end
    return true
end

local function onDownButtonTouch(self, event)
    if (event.phase == "began") then
        Runtime:addEventListener("enterFrame", applyForce)
    elseif (event.phase == "ended") then
        Runtime:removeEventListener("enterFrame", applyForce)
    end
    return true
end

function ui.loadGraphics()

    -- Load Left Arrow Button
    ui.leftButton = display.newImageRect(ui.leftButtonImage, 56, 64)
    ui.leftButton.x = display.screenOriginX + 30
    ui.leftButton.y = display.viewableContentHeight
    ui.leftButton.alpha = .3
    -- Load Right Arrow Button
    ui.rightButton = display.newImageRect(ui.rightButtonImage, 56, 64)
    ui.rightButton.x = display.screenOriginX + 240
    ui.rightButton.y = display.viewableContentHeight
    ui.rightButton.alpha = .3

    -- Load Boost Button
    ui.boostButton = display.newImageRect(ui.buttonImage, 75, 75)
    ui.boostButton.x = display.screenOriginX + 140
    ui.boostButton.y = display.viewableContentHeight
    ui.boostButton.alpha = .3

    ui.leftButton.touch = onLeftButtonTouch
    ui.leftButton:addEventListener("touch", ui.leftButton)

    ui.rightButton.touch = onRightButtonTouch
    ui.rightButton:addEventListener("touch", ui.rightButton)

    ui.boostButton.touch = onDownButtonTouch
    ui.boostButton:addEventListener("touch", ui.boostButton)

end

return scene

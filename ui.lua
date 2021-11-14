
local ui = {

    interaction = false,
    buttonImage = "images/ui/dirUP.png",
    leftButtonImage = "images/ui/dirLEFT.png",
    rightButtonImage = "images/ui/dirRIGHT.png",
    boostButton = nil,
    leftButton = nil,
    rightButton = nil
}

function ui.loadGraphics()
    print("calling ui.loadGraphics")
    local x = display.screenOriginX + display.viewableContentWidth / 2
    -- Load Left Arrow Button
    ui.leftButton = display.newImageRect(ui.leftButtonImage, 56, 64)
    ui.leftButton.x = x - 380
    ui.leftButton.y = display.viewableContentHeight
    ui.leftButton.alpha = .3
    ui.leftButton:scale( 2,2 )

    -- Load Boost Button
    ui.boostButton = display.newImageRect(ui.buttonImage, 75, 75)
    ui.boostButton.x = x
    ui.boostButton.y = display.viewableContentHeight
    ui.boostButton.alpha = .3
    ui.boostButton:scale( 2,2 )

    -- Load Right Arrow Button
    ui.rightButton = display.newImageRect(ui.rightButtonImage, 56, 64)
    ui.rightButton.x = x + 380
    ui.rightButton.y = display.viewableContentHeight
    ui.rightButton.alpha = .3
    ui.rightButton:scale( 2,2 )


    ui.leftButton.touch = onLeftButtonTouch
    ui.leftButton:addEventListener("touch", ui.leftButton)

    ui.rightButton.touch = onRightButtonTouch
    ui.rightButton:addEventListener("touch", ui.rightButton)

    ui.boostButton.touch = onDownButtonTouch
    ui.boostButton:addEventListener("touch", ui.boostButton)
end

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
        --print("Touch down began on: ")
        Runtime:addEventListener("enterFrame", applyForce)
    elseif (event.phase == "ended") then
        --print("Touch down ended on: ")
        Runtime:removeEventListener("enterFrame", applyForce)
    end
    return true
end

return ui
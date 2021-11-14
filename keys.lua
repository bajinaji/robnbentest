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

return onKeyEvent

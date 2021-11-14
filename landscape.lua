local gg = require("common")

local lines = {}

function appendLineWithinScreen(x, y, direction)
    local x2
    if direction == 1 then
        x2 = x + math.random(20, 100)
    else
        x2 = x + math.random(-100, -20)
    end

    if direction == 1 and x2 > display.viewableContentWidth - 1 then
        x2 = display.viewableContentWidth
    elseif direction == -1 and x2 < 0 then
        x2 = 0
    end

    local y2 = y + math.random(-100, 100)
    if y2 > display.viewableContentHeight-1 then
        y2 = display.viewableContentHeight - 1
    elseif y2 < 0 then
        y2 = 0
    end

	print(x..","..y..","..x2..","..y2)

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

    table.insert(lines, line)

    return x2, y2
end

function createLandscape()
    print("Calling create landscape")

    clearLines()

    -- Create landing pad
    print("Creating landing pad")
    local landingPadWidth = 200
    local lx = math.random(landingPadWidth, display.viewableContentWidth - landingPadWidth)
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
    table.insert(lines, line)

    print("Looping and creating landscape around landing pad")
    print("Width of screen:"..display.actualContentWidth)
    -- Create landscape around landing pad
    -- Create to right
    local x = lx + landingPadWidth
    y = ly
    while (x < display.actualContentWidth - 1) do 
		print("appending line to right from x:"..x..",y:"..y)
    	x, y = appendLineWithinScreen(x, y, 1) 
   	end

    -- Create to left
    x = lx
    y = ly
    while (x > 0) do 
    	print("appending line to left from x:"..x..",y:"..y)
    	x, y = appendLineWithinScreen(x, y, -1) 
    end

    print("Finished creating landscape")
end

function clearLines()
	for _, line in ipairs(lines) do
    	display.remove(line)
	end
end

local landscape = {
	createLandscape = createLandscape,
	appendLineWithinScreen = appendLineWithinScreen,
	clearLines = clearLines
}

return landscape
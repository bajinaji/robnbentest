-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

local gg = require("common")

--------------------------------------------
local WallCollisionFilter = { groupIndex = -2 }

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

isos = function( xx, yy, base, height )
    
    local vert1x = xx - ( base / 2 )
    local vert1y = yy + ( height / 3 )
    local vert2x = xx + ( base / 2 )
    local vert2y = yy + ( height / 3 )
    local vert3x = xx
    local vert3y = yy - ( height / 3 * 2 )
    
    local vertices = { vert1x, vert1y, vert2x, vert2y, vert3x, vert3y }
    
    local shape = display.newPolygon( xx, yy, vertices )
    
    return shape
end


-- Called when a key event has been received
local function onKeyEvent( event )
 
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    print( message )
 
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        if ( system.getInfo("platform") == "android" ) then
            return true
        end
    end

	if ( event.keyName == "left") then
		if event.phase == "up" then
			Runtime:removeEventListener( "enterFrame", applyAngularForceLeft )
		elseif event.phase == "down" then
			Runtime:addEventListener( "enterFrame", applyAngularForceLeft )
		end
	elseif ( event.keyName == "right") then
		if event.phase == "up" then
			Runtime:removeEventListener( "enterFrame", applyAngularForceRight )
		elseif event.phase == "down" then
			Runtime:addEventListener( "enterFrame", applyAngularForceRight )
		end
	elseif ( event.keyName == "down") then
		if event.phase == "up" then
			Runtime:removeEventListener( "enterFrame", applyForce )
		elseif event.phase == "down" then
			Runtime:addEventListener( "enterFrame", applyForce )
		end
	end
 
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

function applyAngularForceLeft()
	triangle:applyAngularImpulse( -90 )
end

function applyAngularForceRight()
	triangle:applyAngularImpulse( 90 )
end


function applyForce(obj)
	local q = 10
	local angle = math.rad(triangle.rotation - 90)	
	local xComp = math.cos(angle)
	local yComp = math.sin(angle)
triangle:applyLinearImpulse( xComp * q, yComp * q, triangle.x, triangle.y )
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()

	local leftWall = display.newRect(gg.screenLeft - 25,gg.centerY,50,gg.screenHeight)
physics.addBody(leftWall, "static", {density=0, friction = 0.3, bounce=.2, filter = WallCollisionFilter })
local rightWall = display.newRect(gg.screenWidth + 26,gg.centerY,50,gg.screenHeight)
physics.addBody(rightWall, "static", {density=0, friction = 0.3, bounce=.2, filter = WallCollisionFilter})

local topWall = display.newRect(gg.centerX, gg.screenTop - 26, gg.screenWidth, 50)
physics.addBody(topWall, "static", {density=0, friction = 0.3, bounce=.2, filter = WallCollisionFilter})
local bottomWall = display.newRect(gg.centerX, gg.screenBottom + 25, gg.screenWidth, 50)
physics.addBody(bottomWall, "static", {density=0, friction = 0.3, bounce=.2, filter = WallCollisionFilter})


	physics.setDrawMode( "hybrid" )

	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	--crate.x, crate.y = 160, -100
	--crate.rotation = 15



	local triangleShape = { 0,200, 37,30, -37,30 } 
	triangle = display.newPolygon(halfW, 0, triangleShape);

	--triangle = display.newRect( 0, 0, 100, 100 )
	triangle.x = 200
	triangle.y = 300
	triangle.rotation = 0
	--define the shape table (once created, this can be used multiple times)
	physics.addBody( triangle, { shape=triangleShape, density=3.0, friction=0.0, bounce=0.2 })
	triangle.linearDamping = 3.0
	triangle.angularDamping = 4.0
	triangle.linearDamping = 0.0
	triangle.angularDamping = 0.0


	-- add physics to the crate
	--physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	


	grass2 = display.newImageRect( "grass.png", screenW, 82 )
	grass2.anchorX = 0
	grass2.anchorY = 1
	physics.addBody( grass2, "static", { friction=0.3, shape=grassShape } )
	grass2.x, grass2.y = display.screenOriginX, 0

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( grass)
	--sceneGroup:insert( crate )
end


function scene:show( event )
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
		physics.setGravity( 0, 0 )

		Runtime:addEventListener( "key", onKeyEvent )
	end
end

function scene:hide( event )
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

function scene:destroy( event )

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
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
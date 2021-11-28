-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--require("mobdebug").start()

-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- include the Corona "composer" module
local composer = require "composer"

print ("Loading game menu")

-- load menu screen
--composer.gotoScene( "menu" )
composer.gotoScene("game", "fade", 500)

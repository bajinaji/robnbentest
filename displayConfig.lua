-- Commonly used coordinates
local displayConfig={} 	
	displayConfig.screenLeft = 0
	displayConfig.screenTop = 0
	displayConfig.screenWidth = display.contentWidth
	displayConfig.screenRight = displayConfig.screenLeft + displayConfig.screenWidth
	displayConfig.screenHeight = display.contentHeight
	displayConfig.screenBottom = displayConfig.screenHeight
	displayConfig.screenCenterX = displayConfig.screenWidth / 2
	displayConfig.screenCenterY = displayConfig.screenHeight / 2


return displayConfig
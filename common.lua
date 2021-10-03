-- Commonly used coordinates
local common={} 	
	common.centerX = display.contentCenterX
	common.centerY = display.contentCenterY
	common.screenLeft = display.screenOriginX
	common.screenWidth = display.viewableContentWidth - common.screenLeft * 2
	common.screenRight = common.screenLeft + common.screenWidth
	common.screenTop = display.screenOriginY
	common.screenHeight = display.viewableContentHeight - common.screenTop * 2
	common.screenBottom = common.screenTop + common.screenHeight
	common.screenTopSB = common.screenTop + display.topStatusBarContentHeight -- when status bar is showing
	common.screenHeightSB = display.viewableContentHeight - common.screenTopSB
	common.screenBottomSB = common.screenTopSB + common.screenHeightSB

return common
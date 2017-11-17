local composer = require( "composer" )
local scene = composer.newScene()


local screenW, screenH, halfW, halfY = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local level = 0
local myText
goToMainMenu = function()
	local options =
	{
		effect = "fade", -- See list here: http://docs.coronalabs.com/daily/api/library/composer/gotoScene.html
		params =
		{
			arg1 = level
		}
	}

composer.removeScene( "resultado", false)
	composer.gotoScene( "game", options  )	
end

function scene:create( event )
	local sceneGroup = self.view

	level = event.params.arg1

	myText = display.newText( "Level " .. level, halfW, halfY, native.systemFont, 60 )
	myText:setFillColor( 1, 1, 1 )
	
	composer.removeScene( "game", false)

     local timerHandle = timer.performWithDelay( 2000, goToMainMenu )
	--composer.gotoScene( "level1" )
	
end

function scene:destroy( event )

	myText:removeSelf()
	myText = nil
end



---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
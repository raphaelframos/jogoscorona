display.setStatusBar( display.HiddenStatusBar )
local composer = require( "composer" )
local scene = composer.newScene()
local physics = require "physics"
local passo = 0

local level = 1
local timeTransition = 2000
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

onNext = function ( self, event )
	local options =
	{
		effect = "fade", -- See list here: http://docs.coronalabs.com/daily/api/library/composer/gotoScene.html
		time = 500,
		params =
		{
			arg1 = (level+1)
		}
	}
--	composer.gotoScene( "resultado", options  )
	return true
end

local function onFinalCollision( self, event )

	if ( event.phase == "began" ) then
		physics.pause()
		timer.performWithDelay( 1, onNext )
	end

end



function criaObstaculos( group )

	local  altura = (screenH/3)
	function criaObstaculo1()
		local initialX = 0
		local initialY = altura
		local endX = passo
		local obstaculo = display.newImageRect( "imagem/twitter.png", 30, 30)
		obstaculo.x = initialX
		obstaculo.y = initialY
		physics.addBody( obstaculo, "static")
		group:insert( obstaculo )

		local function listener1()
		    transition.to( obstaculo, { time=timeTransition, x= endX, onComplete=function()
		    	transition.to( obstaculo, { time=timeTransition, x=initialX, onComplete=listener1 } )
		    end } )
		end

		listener1()
	end

	function criaObstaculo2()
		local initialX = passo
		local initialY = 2*altura
		local endX = 2*passo


		local obstaculo2 = display.newImageRect( "imagem/twitter.png", 30, 30)
		obstaculo2.x = endX
		obstaculo2.y = initialY
		physics.addBody( obstaculo2, "static")
		group:insert( obstaculo2 )

		local function listener2()
		    transition.to( obstaculo2, { time=timeTransition, x= initialX, onComplete=function()
		    	transition.to( obstaculo2, { time=timeTransition, x=endX, onComplete=listener2 } )
		    end } )
		end

		listener2()
	end

	function criaObstaculo3()
		local initialX = screenW-20
		local initialY = altura
		local endX = 2*passo


		local obstaculo2 = display.newImageRect( "imagem/twitter.png", 30, 30)
		obstaculo2.x = endX
		obstaculo2.y = initialY
		group:insert( obstaculo2 )

		local function listener2()
		    transition.to( obstaculo2, { time=timeTransition, x= initialX, onComplete=function()
		    	transition.to( obstaculo2, { time=timeTransition, x=endX, onComplete=listener2 } )
		    end } )
		end

		listener2()
	end
	criaObstaculo1()
	criaObstaculo2()
	--criaObstaculo3()
end

function scene:create( event )

	if event.params ~= nil  then
		level = event.params.arg1
	end
  passo = (screenW/3)
	local sceneGroup = self.view
	physics.start()
	physics.pause()

	local myText = display.newText( "Level " .. level, 20, 1, native.systemFont, 10 )
	myText:setFillColor( 0, 0, 0 )
	local tempoTexto = display.newText( "Tempo: " .. level, 20, 10, native.systemFont, 10 )
	tempoTexto:setFillColor( 0, 0, 0 )
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor(1, 1, 1)

	local crate = display.newImageRect( "crate.png", 100, 100 )
	crate.x, crate.y = 160, -100
	crate.rotation = 15

	-- add physics to the crate
	--physics.addBody( crate, "dynamic" , { radius= passo, density=1.0, friction=0.9, bounce=0.3 } )
	crate.myName = "player"

	function criaBalao( x )
		local myCircle = display.newCircle( x, 100, 20 )
		myCircle.strokeWidth = 2
	  myCircle:setStrokeColor( 0, 0, 0 )
		return myCircle
	end

	local groupPlayer = display.newGroup()
	local quantidadeDeBaloes = 3
	local balaoInicial = 0
	for i=1,quantidadeDeBaloes do
			balaoInicial = (balaoInicial+(passo/quantidadeDeBaloes) - 10)
			criaBalao(balaoInicial)

	end
--	groupPlayer:insert(criaBalao(100))
	--physics.addBody( groupPlayer, "dynamic")

	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 10 )
	grass.anchorX = 0
	grass.anchorY = 1

	--  draw the grass at the very bottom of the screen
	grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY

	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW, -1, halfW, -1, halfW, 1, -halfW, 1 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	grass.myName = "chao"
	grass.collision = onFinalCollision
	grass:addEventListener( "collision" )

	physics.setGravity( 0, 1 )
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( grass)
--	sceneGroup:insert( crate )
	criaObstaculos(sceneGroup)

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

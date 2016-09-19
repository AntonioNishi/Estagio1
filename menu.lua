local widget = require "widget"
local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )
	local sceneGroup = self.view

	fundo = display.newImageRect( "woodboard.png", 480, 320 )		
		fundo.x = display.contentWidth/2
		fundo.y = display.contentHeight/2
		sceneGroup:insert(fundo)

	logo = display.newImageRect( "logo1.png", 400, 54 )		
		logo.x = display.contentWidth/2
		logo.y = 65
		sceneGroup:insert(logo)

	function onPlayBtnRelease()		
		composer.gotoScene("gameplay")
	end

	playBtn = widget.newButton{
		width = 200,
        height = 83,
        defaultFile = "button-play.png",
        overFile = "button-play.png",
        onRelease = onPlayBtnRelease
	}
	
	playBtn.x = display.contentWidth/2
	playBtn.y = display.contentHeight/2
	sceneGroup:insert(playBtn)

end

function scene:enterScene( event ) 
	composer.removeScene( "gameplay" )
end

scene:addEventListener( "enterScene", scene )
scene:addEventListener( "create", scene )

return scene
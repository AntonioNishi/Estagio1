-- Bibliotecas utilizadas
local widget = require ("widget")
local composer = require ("composer")
local scene = composer.newScene()

-- Criando variáveis globais.
_W = display.contentWidth
_H = display.contentHeight

puzzlePecasCompleto = 0
totalPuzzlePecas = 9
puzzlePecasLargura, puzzlePecasAltura = 120, 120
puzzlePecaInicioY = { 80,220,360,500,640,780,920,1060,1200 }
puzzlePecaSlideUp = 140
puzzleLargura, puzzleAltura = 320, 320
puzzlePecas = {}

puzzlePecasCheckpoint = { 
	{x=-243,y=76}, --1
	{x=-160, y=76}, --2
	{x=-76, y=74}, --3
	{x=-243,y=177}, --4
	{x=-143, y=157}, --5 
	{x=-57, y=147}, --6
	{x=-261,y=258}, --7
	{x=-176,y=250}, --8
	{x=-74,y=248} --9
}

puzzlePecasPosicaoFinal = { 
	{x=77,y=75}, --1
	{x=160, y=75}, --2
	{x=244, y=75}, --3
	{x=77,y=175}, --4
	{x=179, y=158}, --5
	{x=265, y=144}, --6
	{x=58,y=258}, --7
	{x=145,y=251}, --8
	{x=248,y=247} --9
}

-- Criando grupos Display 
playJogoGroup = display.newGroup()
fimJogoGroup = display.newGroup()

function aleatorio(t)
	local n = #t
	while n > 2 do
		local k = math.random(n)
	    t[n], t[k] = t[k], t[n]
	    n = n - 1
	end
	return t
end

-- Evento de Toque
local function onDrag(event)
	local t = event.target
	
	if event.phase == "began" then
		
		-- Faz com que a peça fique um pouco maior, isso para que foque na peça e que ela fique em cima do tabuleiro.
		t.xScale, t.yScale = 1.3, 1.3
		t:toFront()	
		display.getCurrentStage():setFocus( t )		
        t.isFocus = true 		 			   
        
        -- Guarda posição inicial da peça.           
        xOrigem,yOrigem = t.x,t.y         
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y        

	elseif t.isFocus then
		if "moved" == event.phase then				
			-- Move a peça de acordo com o toque.
			t.x = event.x - t.x0
            t.y = event.y - t.y0                      
		elseif "ended" == event.phase or "cancelled" == event.phase then 
			display.getCurrentStage():setFocus( nil )
            t.isFocus = false     
                            			             
            -- Checa se a peça está no local correto.  
            if t.x <= puzzlePecasCheckpoint[t.id].x + 30 and 
               t.x >= puzzlePecasCheckpoint[t.id].x - 30 and 
               t.y <= puzzlePecasCheckpoint[t.id].y + 30 and 
               t.y >= puzzlePecasCheckpoint[t.id].y - 30 then
              
              	puzzleGroup:insert(t)	 
              	t:toBack()
              	t.place = "moved"
              	
              	t.x, t.y = puzzlePecasPosicaoFinal[t.id].x, puzzlePecasPosicaoFinal[t.id].y
              	t:removeEventListener("touch",onDrag)             	
              	
              	-- Move as peças para cima da figura.
              	for i = 1, totalPuzzlePecas do              		
              		if puzzlePecas[i].place == "start" and puzzlePecas[i].y > yOrigem then
              			puzzlePecas[i].y = puzzlePecas[i].y - puzzlePecaSlideUp              		              		
              		end              		
              	end   
              	      
              	-- Uma vez que for a peça correta, adicione +1 para o total.              	
              	puzzlePecasCompleto = puzzlePecasCompleto + 1
              	
              	-- Cheque se o jogador completou o puzzle.
              	if puzzlePecasCompleto == totalPuzzlePecas then              		
              		playJogoGroup.isVisible = false
              		fimJogoGroup.isVisible = true              		
              	end
              	
	        else
            	-- Se a peça for colocada no local errado, resete a localização da mesma.
				t.xScale,t.yScale = 1,1				
				t.x, t.y = xOrigem, yOrigem
            end              
		end
	end	
	return true
end

function scene:create( event )
	local sceneGroup = self.view

	puzzleGroup = display.newGroup()

	woodBoard = display.newImageRect("woodboard.png", 480, 320)
		woodBoard.x = 562
		woodBoard.y = _H/2
		woodBoard:toBack();
		puzzleGroup:insert(woodBoard)
	
	puzzleFundo = display.newImageRect("puzzle-base.png", puzzleLargura, puzzleAltura)
	puzzleFundo.x, puzzleFundo.y, puzzleFundo.alpha = 160, _H/2, .15
	puzzleGroup:insert(puzzleFundo)
	
	scrollView = widget.newScrollView{ 
		top=0, 
		left = _W - 160,
		height=_H,
		width = 160,
		hideBackground = true, 
		scrollWidth = 50 ,
		scrollHeight = 1000 }
	
	local shufflePuzzleY = aleatorio(puzzlePecaInicioY)
	
	for i = 1, totalPuzzlePecas do		
		puzzlePecas[i] = display.newImageRect(i..".png", puzzlePecasLargura, puzzlePecasAltura)
		puzzlePecas[i].x = 85
		puzzlePecas[i].y = shufflePuzzleY[i] 	
		puzzlePecas[i].id = i
		puzzlePecas[i].place = "start"
		puzzlePecas[i]:addEventListener("touch", onDrag)
		scrollView:insert(puzzlePecas[i])
	end
	
	puzzleGroup:insert(scrollView)
	playJogoGroup:insert(puzzleGroup)	
	
	-- Ajustes nos elementos do jogo.
	function returnToMenu(event)
		if(event.phase == "ended") then
			composer.gotoScene("menu")
		end
	end

	txt_gameComplete = display.newText("Quebra-Cabeça Terminado!!",0,0,120,100,native.systemFont,22)
	txt_gameComplete.x, txt_gameComplete.y = 400, _H/2 - 50
	fimJogoGroup:insert(txt_gameComplete)

	txt_return = display.newText("Retorne ao Menu",0,0,120,100,native.systemFont,22)
	txt_return.x, txt_return.y = 400, _H/2 + 50
	txt_return:addEventListener("touch", returnToMenu)
	fimJogoGroup:insert(txt_return)

	baseBG = display.newImageRect("puzzle-base.png", puzzleLargura, puzzleAltura)
	baseBG.x, baseBG.y = 160, _H/2
	fimJogoGroup:insert(baseBG)

	sceneGroup:insert(fimJogoGroup)
	sceneGroup:insert(playJogoGroup)
	
	fimJogoGroup.isVisible = false
	playJogoGroup.isVisible = true
end

function scene:enterScene( event ) end
function scene:exitScene( event ) end
function scene:destroyScene( event ) end

scene:addEventListener( "create", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene
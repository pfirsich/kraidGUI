gui = require "kraidGUI"
loveBackend = require "kraidGUILove"

function love.load()
	loveBackend.init(gui)

	sceneModeGUI = gui.widgets.Base()
	sceneWindow = gui.widgets.Window{parent = sceneModeGUI, position = {100, 100}, width = 300, height = 600, onMove = function(window, dx, dy) print("MOVE: ", dx, dy) end}
	subWindow = gui.widgets.Window{parent = sceneWindow, position = {100, 100}, width = 200, height = 200}
	sub3Window = gui.widgets.Window{parent = sceneWindow, position = {50, 50}, width = 100, height = 100}
end

function love.update()
	sceneModeGUI:update(loveBackend.uiState())

	if sceneWindow.hovered == false then
		--gui.graphics.drawText("IN EDITOR VIEW", 0, 0)
	end
end

function love.textinput(text)
	if gui.widgets.focused then
		gui.widgets.focused.textInput(text)
	end
end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.mousemoved(x, y, dx, dy)

end

function love.keypressed(key)
	if gui.widgets.focused then
		gui.widgets.focused.keyPressed(key)
	end
end

function love.draw()
	sceneModeGUI:draw()
end

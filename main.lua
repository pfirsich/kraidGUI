gui = require "kraidGUI"
loveBackend = require "kraidGUILove"

function love.load()
	loveBackend.init(gui)

	sceneModeGUI = gui.widgets.Base()
	sceneWindow = gui.widgets.Window{parent = sceneModeGUI, text = "Scene", position = {100, 100}, width = 300, height = 600}
	subWindowA = gui.widgets.Window{parent = sceneWindow, text = "Child A", position = {150, 100}, width = 200, height = 200}
	subWindowB = gui.widgets.Window{parent = sceneWindow, text = "Child B", position = {50, 50}, width = 100, height = 100}
	subBLabel = gui.widgets.Label{parent = subWindowB, text = "Label B2", position = {20, 50}}

	love.graphics.setBackgroundColor(150, 150, 150)
end

function love.update()
	sceneModeGUI:update()

	if sceneWindow.hovered == false then
		gui.graphics.text.draw("IN EDITOR VIEW", 0, 0)
	end
end

function love.textinput(text)
	if gui.widgets.focused then
		gui.widgets.focused.textInput(text)
	end
end

function love.mousepressed(x, y, button)
	sceneWindow:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	sceneWindow:mouseReleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	sceneWindow:mouseMove(x, y, dx, dy)
end

function love.keypressed(key)
	if gui.widgets.focused then
		gui.widgets.focused.keyPressed(key)
	end
end

function love.draw()
	sceneModeGUI:draw()
end

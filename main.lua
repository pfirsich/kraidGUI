gui = require "kraidGUI"
loveBackend = require "kraidGUILove"

function love.load()
	loveBackend.init(gui)

	sceneModeGUI = gui.widgets.Base()

	sceneWindow = gui.widgets.Window{parent = sceneModeGUI, text = "Scene", position = {100, 100}, width = 300, height = 600}

	subWindowB = gui.widgets.Window{parent = sceneWindow, text = "Child B", position = {50, 50}, width = 100, height = 100}
	subBLabel = gui.widgets.Label{parent = subWindowB, text = "Label B2", position = {20, 50}}

	subWindowA = gui.widgets.Window{parent = sceneWindow, text = "Child A", position = {150, 100}, width = 200, height = 200}
	subACheckbox = gui.widgets.Checkbox{parent = subWindowA, position = {5, 120}, onCheck = function(checkbox) subWindowB:setParam("visible", checkbox.checked) end}
	subAButton = gui.widgets.Button{parent = subWindowA, text = "Button A", position = {5, 55}, width = 190, height = 35, onMouseUp = function(button) print("KLICK") end}

	love.graphics.setBackgroundColor(150, 150, 150)
end

function love.update()
	sceneModeGUI:update()
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

	love.graphics.print("subWindowB visible " .. tostring(subWindowB.visible), 0, 25)

	if sceneWindow.hovered == false then
		love.graphics.print("IN EDITOR VIEW", 0, 0)
	end
end

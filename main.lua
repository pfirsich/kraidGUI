gui = require "kraidGUI"
loveBackend = require "kraidGUILove"

function onClose_subWinA(window)
	subACheckbox:setParam("checked", false)
	return true
end

function onChecked_checkboxA(checkbox)
	subWindowB:setParam("visible", checkbox.checked)
end

function propCategoryCollapse(category)
	if not category.collapsed then
		for _, child in ipairs(category.parent.children) do
			if child ~= category and child.type == "Category" then
				child:setParam("collapsed", true)
			end
		end
	end
	categoryLayout:arrange()
end

function love.load()
	loveBackend.init(gui)

	sceneModeGUI = gui.widgets.Base()

	sceneWindow = gui.widgets.Window{parent = sceneModeGUI, text = "Scene", position = {100, 100}, width = 300, height = 600, closeable = false}

	subWindowB = gui.widgets.Window{parent = sceneWindow, text = "Child B", position = {50, 50}, width = 100, height = 100, onClose = onClose_subWinA, breakout = true}
	subBLabel = gui.widgets.Label{parent = subWindowB, text = "Label B2", position = {20, 50}}

	subWindowA = gui.widgets.Window{parent = sceneWindow, text = "Child A", position = {100, 100}, width = 200, height = 200}
	subACheckbox = gui.widgets.Checkbox{parent = subWindowA, position = {5, 120}, checked = true, onChecked = onChecked_checkboxA}
	subAButton = gui.widgets.Button{parent = subWindowA, text = "Button A", position = {5, 55}, width = 190, height = 35, onClicked = function(button) print("KLICK") end}

	propertiesWindow = gui.widgets.Window{parent = sceneModeGUI, text = "Properties", position = {700, 200}, width = 350, height = 600, closeable = false}

	categoryA = gui.widgets.Category{parent = propertiesWindow, text = "Category A", minWidth = 50, inflatedHeight = 200, onCollapse = propCategoryCollapse}
	categoryB = gui.widgets.Category{parent = propertiesWindow, text = "Category B", minWidth = 50, inflatedHeight = 250, onCollapse = propCategoryCollapse}
	categoryLayout = gui.layouts.LineLayout(propertiesWindow, {["spacing"] = 5, ["padding"] = 5, ["padding-top"] = 30})
	categoryLayout:newLine()
	categoryLayout:addWidget(categoryA)
	categoryLayout:newLine()
	categoryLayout:addWidget(categoryB)

	hiddenCheckboxLabel = gui.widgets.Label{parent = categoryA, text = "hidden"}
	hiddenCheckbox = gui.widgets.Checkbox{parent = categoryA}
	enabledCheckboxLabel = gui.widgets.Label{parent = categoryA, text = "enabled"}
	enabledCheckbox = gui.widgets.Checkbox{parent = categoryA}
	loadButton = gui.widgets.Button{parent = categoryA, text = "Load", height = 30, minWidth = 50}
	saveButton = gui.widgets.Button{parent = categoryA, text = "Save", height = 30, minWidth = 50}
	saveAsButton = gui.widgets.Button{parent = categoryA, text = "Save As..", height = 30, minWidth = 50}

	propertiesLayout = gui.layouts.LineLayout(categoryA, {["spacing"] = 5, ["padding"] = 10, ["padding-top"] = 40})
	propertiesLayout:newLine()
	propertiesLayout:addWidget(hiddenCheckbox)
	propertiesLayout:addWidget(hiddenCheckboxLabel)
	propertiesLayout:newLine()
	propertiesLayout:addWidget(enabledCheckbox)
	propertiesLayout:addWidget(enabledCheckboxLabel)
	propertiesLayout:newLine()
	propertiesLayout:addWidget(loadButton)
	propertiesLayout:newLine()
	propertiesLayout:addWidget(saveButton)
	propertiesLayout:addWidget(saveAsButton)

	modeLabel = gui.widgets.Label{parent = categoryB, text = "Edit mode"}

	objectModeRadioLabel = gui.widgets.Label{parent = categoryB, text = "Object Mode"}
	objectModeRadio = gui.widgets.Radiobutton{parent = categoryB, checked = true}

	vertexModeRadioLabel = gui.widgets.Label{parent = categoryB, text = "Vertex Mode"}
	vertexModeRadio = gui.widgets.Radiobutton{parent = categoryB}

	numberWheelLabel = gui.widgets.Label{parent = categoryB, text = "Arbitrary Number"}
	local onChange = function(wheel, value) sceneWindow.position[1] = sceneWindow.position[1] + value - wheel.value end
	numberWheel = gui.widgets.Numberwheel{parent = categoryB, speed = function(x) return 30.0 * x*x end, onChange = onChange}

	modeLayout = gui.layouts.LineLayout(categoryB, {["spacing"] = 5, ["padding"] = 10, ["padding-top"] = 40})
	modeLayout:newLine()
	modeLayout:addWidget(modeLabel)
	modeLayout:newLine()
	modeLayout:addWidget(objectModeRadioLabel)
	modeLayout:addWidget(objectModeRadio)
	modeLayout:newLine()
	modeLayout:addWidget(vertexModeRadioLabel)
	modeLayout:addWidget(vertexModeRadio)
	modeLayout:newLine()
	modeLayout:addWidget(gui.widgets.Line{parent = categoryB})
	modeLayout:newLine()
	modeLayout:addWidget(numberWheelLabel)
	modeLayout:addWidget(numberWheel)

	categoryB:setParam("collapsed", false)
	categoryA:setParam("onResize", function(category) propertiesLayout:arrange() end)
	categoryB:setParam("onResize", function(category) modeLayout:arrange() end)
	propertiesWindow:setParam("onResize", function(window) categoryLayout:arrange() end)
	propertiesWindow:onResize()

	love.graphics.setBackgroundColor(150, 150, 150)
end

function love.update()
	sceneModeGUI:update()
end

function love.mousepressed(x, y, button)
	sceneModeGUI:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	sceneModeGUI:mouseReleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	-- these are two different things, because I want every event to be completely symmetric and behave the same no matter where it was called
	sceneModeGUI:pickHovered(x, y)
	sceneModeGUI:mouseMove(x, y, dx, dy)
end

function love.textinput(text)
	if sceneModeGUI.focused then
		gui.widgets.focused:textInput(text)
	end
end

function love.keypressed(key)
	if sceneModeGUI.focused then
		sceneModeGUI.focused:keyPressed(key)
	end
end

function love.draw()
	sceneModeGUI:draw()

	love.graphics.print("subWindowB visible " .. tostring(subWindowB.visible), 0, 25)

	if sceneModeGUI.hoverd == nil then
		love.graphics.print("IN EDITOR VIEW", 0, 0)
	end
end

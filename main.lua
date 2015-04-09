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

	subWindowB = gui.widgets.Window{parent = sceneWindow, text = "Child B", position = {50, 50}, width = 100, height = 100, onClose = onClose_subWinA, breakout = false}
	subBLabel = gui.widgets.Label{parent = subWindowB, text = "Label B2", position = {20, 50}}

	subWindowA = gui.widgets.Window{parent = sceneWindow, text = "Child A", position = {100, 100}, width = 200, height = 200}
	subACheckbox = gui.widgets.Checkbox{parent = subWindowA, position = {5, 120}, checked = true, onChecked = onChecked_checkboxA}
	subAButton = gui.widgets.Button{parent = subWindowA, text = "Button A", position = {5, 55}, width = 190, height = 35, onClicked = function(button) print("KLICK") end}

	scollBarV = gui.widgets.Scrollbar{parent = sceneWindow, position = {10, 200}, length = 300, vertical = true}
	scollBarH = gui.widgets.Scrollbar{parent = sceneWindow, position = {40, 200}, length = 300, vertical = false}

	propertiesWindow = gui.widgets.Window{parent = sceneModeGUI, text = "Properties", position = {700, 200}, width = 350, height = 600, closeable = false, minWidth = 250, minHeight = 350}

	categoryA = gui.widgets.Category{parent = propertiesWindow, text = "Category A", minWidth = 50, inflatedHeight = 200, onCollapse = propCategoryCollapse}
	categoryB = gui.widgets.Category{parent = propertiesWindow, text = "Category B", minWidth = 50, inflatedHeight = 250, onCollapse = propCategoryCollapse}
	categoryC = gui.widgets.Category{parent = propertiesWindow, text = "TreeView", minWidth = 50, inflatedHeight = 450, onCollapse = propCategoryCollapse}
	categoryLayout = gui.layouts.LineLayout(propertiesWindow, {["spacing"] = 5, ["padding"] = 5, ["padding-top"] = 30})
	categoryLayout:newLine()
	categoryLayout:addWidget(categoryA)
	categoryLayout:newLine()
	categoryLayout:addWidget(categoryB)
	categoryLayout:newLine()
	categoryLayout:addWidget(categoryC)

	hiddenCheckbox = gui.widgets.Checkbox{parent = categoryA}
	hiddenCheckboxLabel = gui.widgets.Label{parent = categoryA, text = "hidden"}
	gui.widgets.helpers.passEvent("onMouseDown", hiddenCheckboxLabel, hiddenCheckbox)
	enabledCheckbox = gui.widgets.Checkbox{parent = categoryA}
	enabledCheckboxLabel = gui.widgets.Label{parent = categoryA, text = "enabled"}
	gui.widgets.helpers.passEvent("onMouseDown", enabledCheckboxLabel, enabledCheckbox)
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

	objectModeRadio = gui.widgets.Radiobutton{parent = categoryB, checked = true}
	objectModeRadioLabel = gui.widgets.Label{parent = categoryB, text = "Object Mode"}
	gui.widgets.helpers.passEvent("onMouseDown", objectModeRadioLabel, objectModeRadio)

	vertexModeRadio = gui.widgets.Radiobutton{parent = categoryB}
	vertexModeRadioLabel = gui.widgets.Label{parent = categoryB, text = "Vertex Mode"}
	gui.widgets.helpers.passEvent("onMouseDown", vertexModeRadioLabel, vertexModeRadio)

	numberWheelLabel = gui.widgets.Label{parent = categoryB, text = "Arbitrary Number"}
	local onChange = function(wheel, value) sceneWindow.position[1] = sceneWindow.position[1] + value - wheel.value end
	numberWheel = gui.widgets.Numberwheel{parent = categoryB, speed = function(x) return 30.0 * x*x end, onChange = onChange}

	lineInputLabel = gui.widgets.Label{parent = categoryB, text = "Line Input: "}
	lineInput = gui.widgets.LineInput{parent = categoryB, text = "Lorem ipsum dolor bla bla", minWidth = 15}

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
	modeLayout:newLine()
	modeLayout:addWidget(lineInputLabel)
	modeLayout:addWidget(lineInput)

	local onClickedTreeElement = function(element) print("Select:", element.text, element.id) end
	treeView = gui.widgets.TreeView{parent = categoryC, position = {10, 40}, height = categoryC.height - 50, onElementClicked = onClickedTreeElement,
		tree = {children = {
			{text = "Letters", children = {
				{text = "A-D", children = {
					{text = "A"},
					{text = "B"},
					{text = "C"},
					{text = "D"},
					{text = "E"},
					{text = "F"},
					{text = "G"},
					{text = "H"},
					{text = "I"},
					{text = "J"},
					{text = "K"},
					{text = "L"},
					{text = "M"},
				}}
			}},
			{text = "Numbers", children = {
				{text = "1", collapsed = true, children = {
					{text = "1"}
				}},
				{text = "2"},
				{text = "3"},
				{text = "4"},
				{text = "5"},
				{text = "6"},
				{text = "7"},
				{text = "8"},
				{text = "9"},
				{text = "10"},
				{text = "11"},
			}}
		}}
	}
	treeView.selected = {treeView.tree.children[2], treeView.tree.children[1].children[1].children[2]}

	categoryB:setParam("collapsed", false)
	categoryA:setParam("onResize", function(category) propertiesLayout:arrange() end)
	categoryB:setParam("onResize", function(category) modeLayout:arrange() end)
	categoryC:setParam("onResize", function(category) treeView:setParam("width", category.width - 20) end)
	propertiesWindow:setParam("onResize", function(window) categoryLayout:arrange() end)
	propertiesWindow:onResize()

	love.graphics.setBackgroundColor(150, 150, 150)
	love.keyboard.setKeyRepeat(true)
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

function widgetToString(widget)
	return widget.type .. (widget.text and " (" .. widget.text .. ")" or "")
end

function love.mousemoved(x, y, dx, dy)
	-- these are two different things, because I want every event to be completely symmetric and behave the same no matter where it was called
	sceneModeGUI:pickHovered(x, y)
	sceneModeGUI:mouseMove(x, y, dx, dy)
end

function love.textinput(text)
	if sceneModeGUI.focused then
		sceneModeGUI.focused:textInput(text)
	end
end

function love.keypressed(key, isrepeat)
	if sceneModeGUI.focused then
		sceneModeGUI.focused:keyPressed(key, isrepeat)
	end

	if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
		if sceneModeGUI.focused and sceneModeGUI.focused.type == "LineInput" then
			if key == "x" then
				love.system.setClipboardText(sceneModeGUI.focused:cut())
			end
			if key == "c" then
				love.system.setClipboardText(sceneModeGUI.focused:selected())
			end
			if key == "v" then
				sceneModeGUI.focused:paste(love.system.getClipboardText())
			end
		end
	end
end

function love.draw()
	sceneModeGUI:draw()

	if sceneModeGUI.hovered == nil then
		love.graphics.print("IN EDITOR VIEW", 0, 0)
	end

	love.graphics.print("subWindowB visible " .. tostring(subWindowB.visible), 0, 20)

	if sceneModeGUI.hovered then
		love.graphics.print("Hovered: " .. widgetToString(sceneModeGUI.hovered), 0, 60)
	end

	if sceneModeGUI.focused then
		love.graphics.print("Focused: " .. widgetToString(sceneModeGUI.focused), 0, 40)
	end
end

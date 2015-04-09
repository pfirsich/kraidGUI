
function module(gui)
	local theme = {name = "default", author = "Joel Schumacher"}

	theme.colors = { -- inspired by https://love2d.org/forums/viewtopic.php?f=5&t=75614 (Gray)
		background = {70, 70, 70},
		border = {45, 45, 45},
		text = {255, 255, 255},
		object = {100, 100, 100},
		objectHighlight = {180, 180, 180},
		marked = {205, 0, 0},
		markedHighlight = {205, 120, 120}
	}

	local hovered = function(self) return self.hovered == self end

	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Base = {}

	function theme.Base.draw(self)
		gui.internal.foreach_array(self.children, function(child)
			child:draw()
		end)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Window = {}

	theme.Window.titleBarBorder = 0
	theme.Window.titleOffsetX = 5
	theme.Window.titleBarHeight = 25

	theme.Window.borderWidth = 2
	theme.Window.resizeHandleSize = 15

	theme.Window.closeButtonWidth = 20
	theme.Window.closeButtonHeight = 8
	theme.Window.closeButtonMargin = theme.Window.closeButtonWidth + 5
	theme.Window.closeButtonPosY = -1

	function theme.Window.init(self)
		self.closeButton:setParam("position", {self.width - self.theme.Window.closeButtonMargin, self.theme.Window.closeButtonPosY})
		self.closeButton:setParam("width", self.theme.Window.closeButtonWidth)
		self.closeButton:setParam("height", self.theme.Window.closeButtonHeight)

		local buttonTheme = {Button = {}}
		buttonTheme.Button.borderWidth = 0
		buttonTheme.colors = {
			objectHighlight = self.theme.colors.objectHighlight,
			object = self.theme.colors.markedHighlight,
			border = self.theme.colors.marked,
			text = self.theme.colors.text
		}
		buttonTheme.Button.draw = self.theme.Button.draw
		self.closeButton:setParam("theme", buttonTheme)
	end

	function theme.Window.mouseMove(self, x, y, dx, dy)
		if self.dragged then
			self.position = {self.position[1] + dx, self.position[2] + dy}
			if self.onMove then self:onMove() end
		end

		if self.resized then
			local clamp = function(v, lo, hi)
				return math.max(lo or -math.huge, math.min(hi or math.huge, v))
			end

			self.width = clamp(self.width + dx, self.minWidth, self.maxWidth)
			self.height = clamp(self.height + dy, self.minHeight, self.maxHeight)
			if self.onResize then self:onResize() end
			self.closeButton:setParam("position", {self.width - self.theme.Window.closeButtonMargin, self.theme.Window.closeButtonPosY})
		end
	end

	function theme.Window.mouseReleased(self, x, y, button)
		if button == "l" then
			self.resized = false
			self.dragged = false
		end
	end

	function theme.Window.onMouseDown(self, x, y, button)
		if button == "l" then
			if y < self.theme.Window.titleBarHeight then
				self.dragged = true
			end

			local fromCorner = {self.width - x, self.height - y}
			if fromCorner[1] + fromCorner[2] < self.theme.Window.resizeHandleSize then
				self.resized = true
			end
		end
	end

	function theme.Window.childrenFilter(self, x, y)
		if gui.internal.inRect({x, y}, {0, 0, self.width, self.height}) then
			if y < self.theme.Window.titleBarHeight then return true end
			if self.width - x + self.height - y < self.theme.Window.resizeHandleSize then return true end
			return false
		else
			return true
		end
	end

	function theme.Window.draw(self)
		gui.graphics.setColor(self.theme.colors.background)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)

		gui.internal.foreach_array(self.children, function(child)
			if not child.breakout then child:draw() end
		end)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(	self.theme.Window.titleBarBorder, self.theme.Window.titleBarBorder,
									self.width - self.theme.Window.titleBarBorder * 2,
									self.theme.Window.titleBarHeight - self.theme.Window.titleBarBorder * 2)

		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, self.theme.Window.titleOffsetX, self.theme.Window.titleBarHeight/2 - gui.graphics.text.getHeight()/2)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Window.borderWidth)
		gui.graphics.drawPolygon({	self.width - self.theme.Window.resizeHandleSize, self.height,
									self.width, self.height,
									self.width, self.height - self.theme.Window.resizeHandleSize})

		self.closeButton:draw()
		if self.closeButton.visible then
			gui.widgets.helpers.withCanvas(self.closeButton, function()
				gui.widgets.helpers.callThemeFunction(self.closeButton, "draw")
			end)
		end

		gui.internal.foreach_array(self.children, function(child)
			if child.breakout then child:draw() end
		end)
	end


	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Label = {}

	function theme.Label.draw(self)
		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, 0, 0)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Button = {}

	theme.Button.borderWidth = 2

	function theme.Button.draw(self)
		local bg = self.clicked and self.theme.colors.objectHighlight or (hovered(self) and self.theme.colors.object or self.theme.colors.border)
		local border = self.clicked and self.theme.colors.border or self.theme.colors.objectHighlight

		gui.graphics.setColor(bg)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Button.borderWidth)

		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, self.width/2 - gui.graphics.text.getWidth(self.text)/2, self.height/2 - gui.graphics.text.getHeight()/2)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Checkbox = {}

	theme.Checkbox.checkSizeFactor = 0.6
	theme.Checkbox.borderWidth = 2
	theme.Checkbox.hoverLineWidth = 2

	function theme.Checkbox.draw(self)
		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Checkbox.borderWidth)

		local w, h = self.width * self.theme.Checkbox.checkSizeFactor, self.height * self.theme.Checkbox.checkSizeFactor
		local x, y = self.width/2 - w/2, self.height/2 - h/2

		gui.graphics.setColor(self.theme.colors.marked)
		if self.checked then gui.graphics.drawRectangle(x, y, w, h) end

		gui.graphics.setColor(self.theme.colors.border)
		if hovered(self) then gui.graphics.drawRectangle(x, y, w, h, self.theme.Checkbox.hoverLineWidth) end
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Radiobutton = {}

	theme.Radiobutton.checkSizeFactor = 0.6
	theme.Radiobutton.borderWidth = 2
	theme.Radiobutton.hoverLineWidth = 2

    function theme.Radiobutton.contains(self, x, y)
        local center = {self.width/2, self.height/2}
        local radius = math.min(self.width, self.height)/2

        local rel = {center[1] - x, center[2] - y}
        return rel[1]*rel[1] + rel[2]*rel[2] < radius*radius
    end

	function theme.Radiobutton.draw(self)
		local centerX, centerY = self.width/2, self.height/2
		local radius = math.min(self.width, self.height)/2 - 1

		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawCircle(centerX, centerY, radius, 16)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawCircle(centerX, centerY, radius, 16, self.theme.Radiobutton.borderWidth)

		gui.graphics.setColor(self.theme.colors.marked)
		if self.checked then gui.graphics.drawCircle(centerX, centerY, radius * self.theme.Radiobutton.checkSizeFactor, 16) end

		gui.graphics.setColor(self.theme.colors.border)
		if hovered(self) then gui.graphics.drawCircle(centerX, centerY, radius * self.theme.Radiobutton.checkSizeFactor, 16, self.theme.Radiobutton.hoverLineWidth) end
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Category = {}

	theme.Category.borderThickness = 5
	theme.Category.textMarginLeft = 5

	function theme.Category.onMouseDown(self, x, y, button)
		if button == "l" then
			if y < self.collapsedHeight then
				self:setCollapsed(not self.collapsed)
			end
		end
	end

	function theme.Category.draw(self)
		gui.graphics.setColor(self.collapsed and self.theme.colors.object or self.theme.colors.objectHighlight)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, theme.Category.textMarginLeft, self.collapsedHeight/2 - gui.graphics.text.getHeight()/2)

		if not self.collapsed then
			gui.graphics.setColor(self.theme.colors.background)
			gui.graphics.drawRectangle(	self.theme.Category.borderThickness, self.collapsedHeight + self.theme.Category.borderThickness,
										self.width - self.theme.Category.borderThickness*2, self.height - self.collapsedHeight - self.theme.Category.borderThickness*2)

			gui.internal.foreach_array(self.children, function(child)
				child:draw()
			end)
		end
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Numberwheel = {}

	theme.Numberwheel.borderThickness = 2
	theme.Numberwheel.wheelBorderThickness = 2
	theme.Numberwheel.smallRadius = 5
	theme.Numberwheel.blownUpRadius = 100
	theme.Numberwheel.wheelMarginLeft = theme.Numberwheel.smallRadius + 5
	theme.Numberwheel.textMarginLeft = theme.Numberwheel.smallRadius + theme.Numberwheel.wheelMarginLeft + 5
	theme.Numberwheel.guidelineCount = 6
	theme.Numberwheel.guidelineThickness = 1
	theme.Numberwheel.wheelAlpha = 150

	function theme.Numberwheel.init(self)
		self.breakout = true
		self.numberInputLine.position = {self.theme.Numberwheel.textMarginLeft, 0}
		self.numberInputLine.width = self.width - self.theme.Numberwheel.textMarginLeft
		self.numberInputLine.height = self.height
	end

	function theme.Numberwheel.contains(self, x, y)
		local rel = {self.theme.Numberwheel.wheelMarginLeft - x, self.height/2 - y}
		local radius = self.blownUp and self.theme.Numberwheel.blownUpRadius or self.theme.Numberwheel.smallRadius
		return rel[1]*rel[1] + rel[2]*rel[2] < radius*radius
	end

	function theme.Numberwheel.mouseMove(self, x, y, dx, dy)
		local function angleDiff(a, b)
			local diff = a - b
			while diff >  180.0 do diff = 360 - diff end
			while diff < -180.0 do diff = 350 + diff end
			return diff
		end

		if self.blownUp then
			local rel = {self.theme.Numberwheel.wheelMarginLeft - x, self.height/2 - y}
			print(rel[1], rel[2])
			local angle = math.atan2(rel[2], rel[1])
			-- finite difference approximation and linearization (only lowest order)
			local dphi = 0
			local epsilon = 1e-10
			dphi = dphi + (math.atan2(rel[2] + epsilon, rel[1]) - angle)/epsilon * dy
			dphi = dphi + (math.atan2(rel[2], rel[1] + epsilon) - angle)/epsilon * dx

			-- NOTE: Check here if radius < 1.0 so outside the wheel nothing happens? It's actually quite useful, albeit unintuitive.
			local radius = math.sqrt(rel[1]*rel[1] + rel[2]*rel[2]) / self.theme.Numberwheel.blownUpRadius
			-- negative sign because I think clockwise increase seems more intuitive
			self:setParam("value", self.value - dphi * (type(self.speed) == "function" and self.speed(radius) or self.speed) * radius)
		end
	end

	function theme.Numberwheel.onMouseDown(self, x, y, button)
		if button == "l" then self.blownUp = true end
	end

	function theme.Numberwheel.mouseReleased(self, x, y, button)
		if button == "l" then self.blownUp = false end
	end

	function theme.Numberwheel.draw(self)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Numberwheel.borderThickness)

		local radius = self.blownUp and self.theme.Numberwheel.blownUpRadius or self.theme.Numberwheel.smallRadius
		local color = {unpack((hovered(self) or hovered(self.numberInputLine)) and self.theme.colors.markedHighlight or self.theme.colors.marked)} -- copy
		color[4] = self.blownUp and self.theme.Numberwheel.wheelAlpha or 255
		gui.graphics.setColor(color)
		gui.graphics.drawCircle(self.theme.Numberwheel.wheelMarginLeft, self.height/2, radius, 32)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawCircle(self.theme.Numberwheel.wheelMarginLeft, self.height/2, radius, 32, self.theme.Numberwheel.wheelBorderThickness)

		if self.blownUp then
			for i = 1, self.theme.Numberwheel.guidelineCount do
				local speed = function(x) return type(self.speed) == "function" and self.speed(x) or self.speed * x end
				local radius = speed(1.0 / self.theme.Numberwheel.guidelineCount * (i - 1)) / speed(1.0)
				gui.graphics.drawCircle(self.theme.Numberwheel.wheelMarginLeft, self.height/2,
										radius * self.theme.Numberwheel.blownUpRadius, 32, self.theme.Numberwheel.guidelineThickness)
			end
		end

		gui.widgets.helpers.withCanvas(self.numberInputLine, function()
			gui.widgets.helpers.callThemeFunction(self.numberInputLine, "draw")
		end)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Line = {}

	function theme.Line.draw(self)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.LineInput = {}

	theme.LineInput.borderThickness = 2
	theme.LineInput.focusBorderThickness = 4
	theme.LineInput.textMargin = 5
	theme.LineInput.cursorThickness = 1
	theme.LineInput.cursorHeight = 0.75
	theme.LineInput.cursorPickPercentage = 0.7 -- the percentage of the character that will result in the cursor being placed left from it#
	theme.LineInput.cursorBlinkFreq = 8.0

	function pickLetter(self, x)
		local getWidth = gui.graphics.text.getWidth
		for i = 1, self.text:len() do
			if x < getWidth(self.text:sub(1, i - 1)) + getWidth(self.text:sub(i,i)) * self.theme.LineInput.cursorPickPercentage + self.theme.LineInput.textMargin then
				return i - 1
			end
		end
		return self.text:len()
	end

	function theme.LineInput.mouseMove(self, x, y, dx, dy)
		if self.selecting then
			local cursor = pickLetter(self, x)
			self.cursor[1] = math.min(cursor, self.startSelect)
			self.cursor[2] = math.max(cursor, self.startSelect)
		end
	end

	function theme.LineInput.mouseReleased(self, x, y, button)
		if button == "l" then self.selecting = false end
	end

	function theme.LineInput.onMouseDown(self, x, y, button)
		if button == "l" then
			local cursor = pickLetter(self, x)
			self.cursor = {cursor, cursor}
			self.startSelect = cursor
			self.selecting = true
		end
	end

	function theme.LineInput.draw(self)
		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)

		-- cursor
		if self.focused == self then
			if math.sin(gui.system.getTime() * self.theme.LineInput.cursorBlinkFreq) > 0.0 or self.cursor[1] ~= self.cursor[2] then
				gui.graphics.setColor(self.theme.colors.border)
				gui.graphics.drawRectangle(	gui.graphics.text.getWidth(self.text:sub(1, self.cursor[1])) + self.theme.LineInput.textMargin,
											(1.0 - self.theme.LineInput.cursorHeight) / 2 * self.height,
											math.max(gui.graphics.text.getWidth(self.text:sub(self.cursor[1] + 1, self.cursor[2])), self.theme.LineInput.cursorThickness),
											self.height * self.theme.LineInput.cursorHeight)
			end
		end

		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, self.theme.LineInput.textMargin, self.height/2 - gui.graphics.text.getHeight()/2)

		if self.focused == self then
			gui.graphics.setColor(self.theme.colors.objectHighlight)
			gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.LineInput.focusBorderThickness)
		end

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.LineInput.borderThickness)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Scrollbar = {}

	theme.Scrollbar.buttonSize = 20
	theme.Scrollbar.borderSize = 2

	function theme.Scrollbar.init(self)
		self.buttonMinus = gui.widgets.Button{parent = self, text = "", position = {0, 0}, onClicked = function() self:scrollDown() end}
		gui.widgets.helpers.passEvent("onMouseDown", self.buttonMinus, self)
		self.buttonPlus = gui.widgets.Button{parent = self, text = "", onClicked = function() self:scrollUp() end}
		gui.widgets.helpers.passEvent("onMouseDown", self.buttonPlus, self)

		local scrubberTheme = {Button = {}, colors = self.theme.colors}
		gui.internal.addTableKeys(scrubberTheme.Button, self.theme.Button)

		function scrubberTheme.Button.onMouseDown(scrubber, x, y, button)
			if button == "l" then
				scrubber.dragged = true
				scrubber.lastScrollRelativeScrubberPos = {x, y}
			end
			if button == "wu" or button == "wd" then self:onMouseDown(x, y, button) end
		end

		function scrubberTheme.Button.mouseMove(scrubber, x, y, dx, dy)
			if scrubber.dragged then
				local dValue_dXY = 1.0 / (self.length - self.theme.Scrollbar.buttonSize*2 - self.scrubberLength)
				self.value = math.max(0, math.min(1, self.value + dValue_dXY * (self.vertical and dy or dx)))
			end
		end

		function scrubberTheme.Button.mouseReleased(scrubber, x, y, button)
			if button == "l" then scrubber.dragged = false end
		end

		self.scrubberLength = 50
		self.scrubber = gui.widgets.Button{parent = self, text = "", onClicked = function() end, theme = scrubberTheme}
	end

	function theme.Scrollbar.update(self)
		local size = self.vertical and {self.width, self.theme.Scrollbar.buttonSize} or {self.theme.Scrollbar.buttonSize, self.height}
		self.buttonMinus:setParam("width", size[1])
		self.buttonMinus:setParam("height", size[2])
		self.buttonPlus:setParam("width", size[1])
		self.buttonPlus:setParam("height", size[2])

		local plusPos = self.vertical and {0, self.height - self.theme.Scrollbar.buttonSize} or {self.width - self.theme.Scrollbar.buttonSize, 0}
		self.buttonPlus:setParam("position", plusPos)

		self.scrubber:setParam(self.vertical and "height" or "width", self.scrubberLength)
		self.scrubber:setParam(self.vertical and "width" or "height", self.thickness)

		local scrubberPos = self.theme.Scrollbar.buttonSize + self.value * (self.length - self.theme.Scrollbar.buttonSize*2 - self.scrubberLength)
		self.scrubber:setParam("position", self.vertical and {0, scrubberPos} or {scrubberPos, 0})
	end

	function theme.Scrollbar.draw(self)
		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)

		gui.internal.foreach_array(self.children, function(child) child:draw() end)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.TreeView = {}

	theme.TreeView.borderThickness = 2
	theme.TreeView.marginTop = 5
	theme.TreeView.textMarginLeft = 30
	theme.TreeView.circleMarginLeft = 16
	theme.TreeView.elementHeight = 20
	theme.TreeView.indentWidth = 25
	theme.TreeView.smallCircleRadius = 3 -- uncollapsed
	theme.TreeView.bigCircleRadius = 7 -- collapsed
	theme.TreeView.circleThickness = 2
	theme.TreeView.selectionMarginLeftRight = 5

	function theme.TreeView.init(self)
		self.scrollbar = gui.widgets.Scrollbar{parent = self}
		self.scroll = 0
	end

	function theme.TreeView.update(self)
		self.straightenedTree = {}
		local showDepth = -1
		for i = 1, #self.linearizedTree do
			if self.linearizedTree[i].depth <= showDepth or showDepth < 0 then
				self.straightenedTree[#self.straightenedTree+1] = self.linearizedTree[i]

				if self.linearizedTree[i].collapsed then
					showDepth = self.linearizedTree[i].depth
				else
					showDepth = -1
				end
			end
		end

		self.scrollbar:setParam("position", {self.width - self.scrollbar.width, 0})
		self.scrollbar:setParam("length", self.height)

		local overlap = #self.straightenedTree * self.theme.TreeView.elementHeight - self.height
		local overlapFrac = self.height / (#self.straightenedTree * self.theme.TreeView.elementHeight)
		if overlap > 0 then
			self.scrollbar:setParam("visible", true)
			self.scrollbar.scrubberLength = (self.scrollbar.height - self.scrollbar.theme.Scrollbar.buttonSize * 2) * overlapFrac
			self.scroll = self.scrollbar.value * overlap
		else
			self.scrollbar:setParam("visible", false)
			self.scroll = 0
		end
	end

	function theme.TreeView.onMouseDown(self, x, y, button)
		if button == "l" then
			local index = math.floor((y - self.theme.TreeView.marginTop + self.scroll) / self.theme.TreeView.elementHeight) + 1
			if index >= 1 and index <= #self.straightenedTree then
				x = x - self.straightenedTree[index].depth * self.theme.TreeView.indentWidth

				if x > 0 and x < theme.TreeView.textMarginLeft then
					self.straightenedTree[index].collapsed = not self.straightenedTree[index].collapsed
				else
					if (gui.system.keyDown("lshift") or gui.system.keyDown("rshift")) and self.multiSelect then
						self.selected[#self.selected+1] = self.straightenedTree[index]
					else
						self.selected = {self.straightenedTree[index]}
					end
				end
			end
		end

		if button == "wd" then self.scrollbar:scrollUp() end
		if button == "wu" then self.scrollbar:scrollDown() end
	end

	function theme.TreeView.draw(self)
		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.TreeView.borderThickness)

		local y = self.theme.TreeView.marginTop - self.scroll
		for i = 1, #self.straightenedTree do
			local node = self.straightenedTree[i]

			local x = node.depth * self.theme.TreeView.indentWidth

			local selected = false
			for i = 1, #self.selected do
				if node == self.selected[i] then selected = true; break end
			end
			if selected then
				gui.graphics.setColor(self.theme.colors.border)
				gui.graphics.drawRectangle(	theme.TreeView.selectionMarginLeftRight, y,
											self.width - theme.TreeView.selectionMarginLeftRight*2, self.theme.TreeView.elementHeight)
			end

			if node.children and #node.children > 0 then
				gui.graphics.setColor(self.theme.colors.objectHighlight)
				local radius = node.collapsed and self.theme.TreeView.bigCircleRadius or self.theme.TreeView.smallCircleRadius
				gui.graphics.drawCircle(self.theme.TreeView.circleMarginLeft + x,
										self.theme.TreeView.elementHeight/2 + y,
										radius, 16, self.theme.TreeView.circleThickness)
			end

			gui.graphics.setColor(self.theme.colors.text)
			gui.graphics.text.draw(node.text, self.theme.TreeView.textMarginLeft + x, self.theme.TreeView.elementHeight/2 - gui.graphics.text.getHeight()/2 + y)

			y = y + self.theme.TreeView.elementHeight
		end

		self.scrollbar:draw()
	end

	return theme
end

return module
